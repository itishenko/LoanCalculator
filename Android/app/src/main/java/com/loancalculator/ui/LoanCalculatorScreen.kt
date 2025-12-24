package com.loancalculator.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.filled.Percent
import androidx.compose.material.icons.filled.AttachMoney
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.loancalculator.redux.LoanAction
import com.loancalculator.redux.Store
import com.loancalculator.redux.SubmissionResult
import com.loancalculator.ui.components.CustomSlider
import com.loancalculator.ui.theme.*
import com.loancalculator.utils.NumberFormatter
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoanCalculatorScreen(
    store: Store,
    modifier: Modifier = Modifier
) {
    val state by store.state.collectAsState()
    val scope = rememberCoroutineScope()
    
    var showDialog by remember { mutableStateOf(false) }
    
    // Load saved state on first composition
    LaunchedEffect(Unit) {
        store.dispatch(LoanAction.LoadSavedState)
    }
    
    // Show dialog when submission result changes
    LaunchedEffect(state.submissionResult) {
        showDialog = state.submissionResult != null
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Loan Calculator",
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(32.dp)
        ) {
            SliderSection(
                title = "How much?",
                value = state.amount.toFloat(),
                valueRange = 5000f..50000f,
                step = 1000f,
                displayValue = "₦${NumberFormatter.formatAsCurrency(state.amount)}",
                trackColor1 = GreenSliderDark,
                trackColor2 = GreenSliderLight,
                onValueChange = { newValue ->
                    store.dispatch(LoanAction.SetAmount(newValue.toDouble()))
                }
            )
            
            PeriodSliderSection(
                selectedPeriod = state.periodDays,
                onPeriodChange = { newPeriod ->
                    store.dispatch(LoanAction.SetPeriod(newPeriod))
                }
            )
            
            CalculationSection(state = state)
            
            Spacer(modifier = Modifier.weight(1f))
            
            SubmitButton(
                enabled = state.isValid && !state.isLoading,
                isLoading = state.isLoading,
                onClick = {
                    scope.launch {
                        store.dispatch(LoanAction.SubmitApplication)
                    }
                }
            )
        }
    }
    
    if (showDialog) {
        state.submissionResult?.let { result ->
            ResultDialog(
                result = result,
                onDismiss = {
                    showDialog = false
                    store.dispatch(LoanAction.DismissResult)
                }
            )
        }
    }
}

@Composable
fun SliderSection(
    title: String,
    value: Float,
    valueRange: ClosedFloatingPointRange<Float>,
    step: Float,
    displayValue: String,
    trackColor1: Color,
    trackColor2: Color,
    onValueChange: (Float) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Medium
            )
            Text(
                text = displayValue,
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
        }
        
        CustomSlider(
            value = value,
            onValueChange = { newValue ->
                // Round to step
                val stepped = (Math.round(newValue / step) * step)
                onValueChange(stepped.coerceIn(valueRange))
            },
            valueRange = valueRange,
            trackColor1 = trackColor1,
            trackColor2 = trackColor2
        )
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = NumberFormatter.formatAsCurrency(valueRange.start.toDouble()),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = NumberFormatter.formatAsCurrency(valueRange.endInclusive.toDouble()),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun PeriodSliderSection(
    selectedPeriod: Int,
    onPeriodChange: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val periods = listOf(7, 14, 21, 28)
    val periodIndex = periods.indexOf(selectedPeriod).coerceAtLeast(0)
    
    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "How long?",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Medium
            )
            Text(
                text = "$selectedPeriod days",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
        }
        
        CustomSlider(
            value = periodIndex.toFloat(),
            onValueChange = { newValue ->
                val index = newValue.toInt().coerceIn(periods.indices)
                onPeriodChange(periods[index])
            },
            valueRange = 0f..(periods.size - 1).toFloat(),
            trackColor1 = OrangeSliderDark,
            trackColor2 = OrangeSliderLight
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "7",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = "28",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun SubmitButton(
    enabled: Boolean,
    isLoading: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.primary,
            disabledContainerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        AnimatedVisibility(
            visible = isLoading,
            enter = fadeIn(),
            exit = fadeOut()
        ) {
            CircularProgressIndicator(
                modifier = Modifier.size(24.dp),
                color = MaterialTheme.colorScheme.onPrimary,
                strokeWidth = 3.dp
            )
        }
        
        AnimatedVisibility(
            visible = !isLoading,
            enter = fadeIn(),
            exit = fadeOut()
        ) {
            Text(
                text = "Submit Application",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
fun CalculationSection(
    state: com.loancalculator.redux.LoanState,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        CalculationRow(
            icon = Icons.Default.Percent,
            title = "Interest Rate",
            value = NumberFormatter.formatAsPercentage(state.interestRate),
            iconColor = MaterialTheme.colorScheme.primary
        )
        
        CalculationRow(
            icon = Icons.Default.AttachMoney,
            title = "Total Repayment",
            value = "₦${NumberFormatter.formatAsCurrency(state.totalRepayment)}",
            iconColor = MaterialTheme.colorScheme.tertiary
        )
        
        CalculationRow(
            icon = Icons.Default.CalendarMonth,
            title = "Repayment Date",
            value = NumberFormatter.formatAsShortDate(state.repaymentDate),
            iconColor = MaterialTheme.colorScheme.secondary
        )
    }
}

@Composable
fun CalculationRow(
    icon: ImageVector,
    title: String,
    value: String,
    iconColor: Color,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = iconColor,
                modifier = Modifier.size(28.dp)
            )
            
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = value,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface
                )
            }
        }
    }
}

@Composable
fun ResultDialog(
    result: SubmissionResult,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        icon = {
            when (result) {
                is SubmissionResult.Success -> {
                    Icon(
                        imageVector = Icons.Default.CheckCircle,
                        contentDescription = "Success",
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(48.dp)
                    )
                }
                is SubmissionResult.Failure -> {
                    Icon(
                        imageVector = Icons.Default.Error,
                        contentDescription = "Error",
                        tint = MaterialTheme.colorScheme.error,
                        modifier = Modifier.size(48.dp)
                    )
                }
            }
        },
        title = {
            Text(
                text = when (result) {
                    is SubmissionResult.Success -> "Success! 🎉"
                    is SubmissionResult.Failure -> "Error"
                }
            )
        },
        text = {
            Text(
                text = when (result) {
                    is SubmissionResult.Success ->
                        "Your loan application has been submitted successfully.\n\nReference ID: #${result.responseId}"
                    is SubmissionResult.Failure ->
                        result.message
                }
            )
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("OK")
            }
        }
    )
}

