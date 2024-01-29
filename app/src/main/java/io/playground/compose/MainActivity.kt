package io.playground.compose

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ModifierInfo
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import io.playground.compose.common.Screen
import kotlin.random.Random

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            ActivityScreen()
        }
    }

    @Composable
    private fun ActivityScreen() {
        Screen {
            Column (
                modifier = Modifier.fillMaxSize()
            ) {
                Image(painter = painterResource(id = R.drawable.icon_pin_vector), contentDescription = null)
                Image(painter = painterResource(id = R.drawable.icon_pin_rasterized), contentDescription = null)
            }
        }
    }

    @Preview
    @Composable
    private fun ActivityScreenPreview() {
        ActivityScreen()
    }

}