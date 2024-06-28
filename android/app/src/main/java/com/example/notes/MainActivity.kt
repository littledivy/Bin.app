package com.example.notes

import android.os.Bundle
import android.view.RoundedCorner
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.calculateEndPadding
import androidx.compose.foundation.layout.calculateStartPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.tooling.preview.Preview
import coil.compose.AsyncImage
import coil.compose.SubcomposeAsyncImage
import coil.compose.rememberAsyncImagePainter
import io.github.alexzhirkevich.cupertino.theme.CupertinoTheme
import io.github.alexzhirkevich.cupertino.CupertinoScaffold
import io.github.alexzhirkevich.cupertino.CupertinoTopAppBar
import io.github.alexzhirkevich.cupertino.CupertinoText
import io.github.alexzhirkevich.cupertino.CupertinoNavigationTitle
import io.github.alexzhirkevich.cupertino.CupertinoSearchTextField
import io.github.alexzhirkevich.cupertino.CupertinoSearchTextFieldDefaults

import io.github.alexzhirkevich.cupertino.ExperimentalCupertinoApi
import io.github.alexzhirkevich.cupertino.section.CupertinoSection
import io.github.alexzhirkevich.cupertino.section.SectionLink
import io.github.alexzhirkevich.cupertino.section.sectionContainerBackground

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CupertinoTheme {
                    Greeting("Android")
            }
        }
    }
}

@Composable
private operator fun PaddingValues.plus(other : PaddingValues) : PaddingValues{
    val layoutDirection = LocalLayoutDirection.current

    return PaddingValues(
        top = calculateTopPadding() + other.calculateTopPadding(),
        bottom = calculateBottomPadding() + other.calculateBottomPadding(),
        start = calculateStartPadding(layoutDirection) + other.calculateStartPadding(layoutDirection),
        end = calculateEndPadding(layoutDirection) + other.calculateEndPadding(layoutDirection)
    )
}

@OptIn(ExperimentalCupertinoApi::class)
@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    CupertinoScaffold (
        hasNavigationTitle = true,
        topBar = {
            CupertinoTopAppBar(
                title = {
                    CupertinoText("Hello")
                }
            )
        }
    ) {pv ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .sectionContainerBackground()
                .padding(pv)
                .padding(top = 10.dp)
        ) {
            CupertinoNavigationTitle {
                CupertinoText("Home")
            }

            var searchValue by remember {
                mutableStateOf("")
            }
            CupertinoSearchTextField(
                value = searchValue,
                onValueChange = {
                    searchValue = it
                },
                paddingValues = CupertinoSearchTextFieldDefaults.PaddingValues +
                        PaddingValues(bottom = 12.dp)
            )

            CupertinoSection {
                SectionLink(
                    onClick = {},
                ) {
                    CupertinoText("Hello")
                }

                SectionLink(
                    onClick = {},
                ) {
                    CupertinoText("Test test")
                }


                SectionLink(
                    onClick = {},
                ) {
                    CupertinoText("Note title")
                }
            }

            CupertinoNavigationTitle {
                CupertinoText("Images")
            }

            PhotoGrid()
        }
    }
}

@Composable
fun PhotoGrid() {
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = 150.dp),
        Modifier.padding(
            horizontal = 16.dp
        ).clip(RoundedCornerShape(topEnd = 8.dp , topStart = 8.dp))
    ) {
        items(10) { index ->
            AsyncImage(
                model = "https://picsum.photos/seed/${0.2 * index}/300/300",
                contentDescription = null,
                contentScale = ContentScale.FillWidth,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    CupertinoTheme { Greeting("Android") }
}