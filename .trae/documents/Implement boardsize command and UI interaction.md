## Implementation Plan

### 1. Implement boardsize command in gtp_cmd.gd
- Add a new function `boardsize_async(size)` that sends the `boardsize` command with the specified size
- The function should follow the same pattern as other command functions, returning a `CmdResponse` object
- Handle different response formats (with/without ID, with/without response)

### 2. Implement UI interaction in main_ui.gd
- Connect the `_set_board_size_button.pressed` signal to a new handler function `_on_set_board_size_button_pressed`
- In the handler function:
  - Get the selected board size from `_board_size_option`
  - Call `_gtp_cmd.boardsize_async()` with the selected size
  - After receiving the response, call `_gtp_cmd.showboard_async()` to refresh the board
  - Update the UI with the new board state, including captured stones counts
  - Trigger a redraw of the board

### 3. Testing
- Ensure the boardsize command works correctly according to the GTP protocol specification
- Verify the UI interaction flows smoothly
- Test with different board sizes to ensure compatibility

### 4. Code Quality
- Follow the existing code style and naming conventions
- Add appropriate comments where necessary
- Ensure error handling is consistent with other command functions