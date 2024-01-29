package io.playground.compose.common

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import io.playground.compose.ui.theme.ComposePlaygroundTheme

@Composable
fun Screen(content: @Composable () -> Unit) {
    ComposePlaygroundTheme {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight()
                .background(Color(0xFF151C27))
                .padding(16.dp)
        ) {
            content()
        }
    }
}