package com.loancalculator.network

import com.google.gson.annotations.SerializedName

/**
 * Loan Application request model
 */
data class LoanApplication(
    @SerializedName("amount")
    val amount: Double,
    
    @SerializedName("period")
    val period: Int,
    
    @SerializedName("totalRepayment")
    val totalRepayment: Double
)

/**
 * Loan Application response model
 */
data class LoanApplicationResponse(
    @SerializedName("id")
    val id: Int,
    
    @SerializedName("amount")
    val amount: Double,
    
    @SerializedName("period")
    val period: Int,
    
    @SerializedName("totalRepayment")
    val totalRepayment: Double
)

