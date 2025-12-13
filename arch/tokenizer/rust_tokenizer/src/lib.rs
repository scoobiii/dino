#[no_mangle]
pub extern "C" fn tokenize_len(text_ptr: *const u8, text_len: usize) -> usize {
    let text = unsafe { std::slice::from_raw_parts(text_ptr, text_len) };
    let s = std::str::from_utf8(text).unwrap_or("");
    s.split_whitespace().count() + 2
}

#[no_mangle]
pub extern "C" fn tokenize(text_ptr: *const u8, text_len: usize, out_ptr: *mut u32) -> usize {
    let text = unsafe { std::slice::from_raw_parts(text_ptr, text_len) };
    let s = std::str::from_utf8(text).unwrap_or("");
    let mut tokens = Vec::with_capacity(s.split_whitespace().count() + 2);
    tokens.push(1); // <s>
    for word in s.split_whitespace() {
        let hash = word.bytes().fold(0u32, |h, b| h.wrapping_mul(31).wrapping_add(b as u32));
        tokens.push((hash % 4091) + 4);
    }
    tokens.push(2); // </s>
    let n = tokens.len();
    unsafe { std::ptr::copy_nonoverlapping(tokens.as_ptr(), out_ptr, n); }
    n
}
