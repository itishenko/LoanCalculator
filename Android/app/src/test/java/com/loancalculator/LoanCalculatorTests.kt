package com.loancalculator

import com.loancalculator.redux.*
import com.loancalculator.utils.NumberFormatter
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import java.util.Calendar

/**
 * Loan State Tests
 */
class LoanStateTests {
    
    @Test
    fun `test default state`() {
        val state = LoanState()
        
        assertEquals(5000.0, state.amount, 0.01)
        assertEquals(14, state.periodDays)
        assertEquals(0.15, state.interestRate, 0.01)
        assertFalse(state.isLoading)
        assertNull(state.submissionResult)
    }
    
    @Test
    fun `test total repayment calculation`() {
        val state = LoanState(
            amount = 10000.0,
            interestRate = 0.15
        )
        
        val expectedRepayment = 10000.0 * 1.15
        assertEquals(expectedRepayment, state.totalRepayment, 0.01)
    }
    
    @Test
    fun `test repayment date calculation`() {
        val state = LoanState(periodDays = 14)
        
        val expectedDate = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 14)
        }
        
        val actualDate = Calendar.getInstance().apply {
            time = state.repaymentDate
        }
        
        assertEquals(
            expectedDate.get(Calendar.DAY_OF_YEAR),
            actualDate.get(Calendar.DAY_OF_YEAR)
        )
    }
    
    @Test
    fun `test validation - valid state`() {
        val state = LoanState(
            amount = 10000.0,
            periodDays = 14
        )
        
        assertTrue(state.isValid)
    }
    
    @Test
    fun `test validation - invalid amount too low`() {
        val state = LoanState(
            amount = 4000.0,
            periodDays = 14
        )
        
        assertFalse(state.isValid)
    }
    
    @Test
    fun `test validation - invalid amount too high`() {
        val state = LoanState(
            amount = 60000.0,
            periodDays = 14
        )
        
        assertFalse(state.isValid)
    }
    
    @Test
    fun `test validation - invalid period`() {
        val state = LoanState(
            amount = 10000.0,
            periodDays = 10 // Not in allowed periods
        )
        
        assertFalse(state.isValid)
    }
    
    @Test
    fun `test validation - all valid periods`() {
        val validPeriods = listOf(7, 14, 21, 28)
        
        validPeriods.forEach { period ->
            val state = LoanState(
                amount = 10000.0,
                periodDays = period
            )
            
            assertTrue("Period $period should be valid", state.isValid)
        }
    }
}

/**
 * Loan Reducer Tests
 */
class LoanReducerTests {
    
    @Test
    fun `test set amount action`() {
        val state = LoanState()
        val newState = loanReducer(state, LoanAction.SetAmount(15000.0))
        
        assertEquals(15000.0, newState.amount, 0.01)
        assertNull(newState.submissionResult)
    }
    
    @Test
    fun `test set period action`() {
        val state = LoanState()
        val newState = loanReducer(state, LoanAction.SetPeriod(21))
        
        assertEquals(21, newState.periodDays)
        assertNull(newState.submissionResult)
    }
    
    @Test
    fun `test submission started action`() {
        val state = LoanState(
            submissionResult = SubmissionResult.Success(123)
        )
        val newState = loanReducer(state, LoanAction.SubmissionStarted)
        
        assertTrue(newState.isLoading)
        assertNull(newState.submissionResult)
    }
    
    @Test
    fun `test submission success action`() {
        val state = LoanState(isLoading = true)
        val newState = loanReducer(state, LoanAction.SubmissionSuccess(456))
        
        assertFalse(newState.isLoading)
        assertTrue(newState.submissionResult is SubmissionResult.Success)
        assertEquals(456, (newState.submissionResult as SubmissionResult.Success).responseId)
    }
    
    @Test
    fun `test submission failure action`() {
        val state = LoanState(isLoading = true)
        val newState = loanReducer(state, LoanAction.SubmissionFailure("Network error"))
        
        assertFalse(newState.isLoading)
        assertTrue(newState.submissionResult is SubmissionResult.Failure)
        assertEquals(
            "Network error",
            (newState.submissionResult as SubmissionResult.Failure).message
        )
    }
    
    @Test
    fun `test dismiss result action`() {
        val state = LoanState(
            submissionResult = SubmissionResult.Success(789)
        )
        val newState = loanReducer(state, LoanAction.DismissResult)
        
        assertNull(newState.submissionResult)
    }
}

/**
 * Number Formatter Tests
 */
class NumberFormatterTests {
    
    @Test
    fun `test format as currency`() {
        assertEquals("5,000", NumberFormatter.formatAsCurrency(5000.0))
        assertEquals("10,000", NumberFormatter.formatAsCurrency(10000.0))
        assertEquals("50,000", NumberFormatter.formatAsCurrency(50000.0))
        assertEquals("1,234,567", NumberFormatter.formatAsCurrency(1234567.0))
    }
    
    @Test
    fun `test format as percentage`() {
        assertEquals("15%", NumberFormatter.formatAsPercentage(0.15))
        assertEquals("20%", NumberFormatter.formatAsPercentage(0.20))
        assertEquals("7%", NumberFormatter.formatAsPercentage(0.075))
    }
    
    @Test
    fun `test format as short date`() {
        val date = Calendar.getInstance().time
        val formatted = NumberFormatter.formatAsShortDate(date)
        
        assertNotNull(formatted)
        assertTrue(formatted.isNotEmpty())
    }
}

/**
 * Integration Tests
 */
class IntegrationTests {
    
    @Test
    fun `test complete user flow`() {
        var state = LoanState()
        
        // User selects amount
        state = loanReducer(state, LoanAction.SetAmount(15000.0))
        assertEquals(15000.0, state.amount, 0.01)
        
        // User selects period
        state = loanReducer(state, LoanAction.SetPeriod(21))
        assertEquals(21, state.periodDays)
        
        // Verify calculations
        assertEquals(17250.0, state.totalRepayment, 0.01) // 15000 * 1.15
        assertTrue(state.isValid)
        
        // Simulate submission
        state = loanReducer(state, LoanAction.SubmissionStarted)
        assertTrue(state.isLoading)
        
        // Simulate success
        state = loanReducer(state, LoanAction.SubmissionSuccess(999))
        assertFalse(state.isLoading)
        assertEquals(999, (state.submissionResult as SubmissionResult.Success).responseId)
        
        // Dismiss result
        state = loanReducer(state, LoanAction.DismissResult)
        assertNull(state.submissionResult)
    }
    
    @Test
    fun `test edge case - minimum values`() {
        val state = LoanState(
            amount = 5000.0,
            periodDays = 7
        )
        
        assertTrue(state.isValid)
        assertEquals(5750.0, state.totalRepayment, 0.01)
    }
    
    @Test
    fun `test edge case - maximum values`() {
        val state = LoanState(
            amount = 50000.0,
            periodDays = 28
        )
        
        assertTrue(state.isValid)
        assertEquals(57500.0, state.totalRepayment, 0.01)
    }
}

