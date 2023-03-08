# Clockwork - A QML Demo Application (Qt 6.2 LTS)

This demo quickly demonstrates QML capabilities with embedded JavaScript and a fragment shader.

The application opens a full screen window with Salvador Dali's famous painting in the background. There is a wobbling clock displayed on the foreground, moving around and bouncing from the window borders.

The clock displays current time in the beginning, and when cursor is moved on top of it, it advances the time displayed, adding to the score.

The clock tries to avoid the cursor and increases also speed when the cursor is near. The speed gradually returns to normal when the cursor is not close to the clock.

The current version supports two languages which can be changed at runtime.
