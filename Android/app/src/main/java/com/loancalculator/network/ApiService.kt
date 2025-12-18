package com.loancalculator.network

import retrofit2.http.Body
import retrofit2.http.POST

/**
 * API Service interface for Retrofit
 */
interface ApiService {
    @POST("posts")
    suspend fun submitApplication(
        @Body application: LoanApplication
    ): LoanApplicationResponse
}

