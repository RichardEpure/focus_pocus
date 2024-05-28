# Project setup
*Requires [python 3.11+](https://www.python.org/downloads/) and [Autohotkey v2](https://www.autohotkey.com/)*
1. `git clone` repo-url
2. `py -m venv env`
3. `.\env\Scripts\activate`
4. `pip install -r .\requirements.txt`
5. `py build.py`

# Listening for hid data via QMK
You can refer to the [QMK docs](https://docs.qmk.fm/#/feature_rawhid?id=raw-hid) for detailed information.
Personally I only need to switch from my base layer to my gaming layer (or vice versa) so this code snippet is all I needed
to add to my `keymap.c` file. *Note that I'm using Vial which requires me to use `raw_hid_receive_kb` instead of the standard `raw_hid_receive`.*
```c
void raw_hid_receive_kb(uint8_t *data, uint8_t length) {
    if (data[0] == 0x87) {
        layer_move(_GAMING);
    } else if (data[0] == 0x86) {
        layer_move(_BASE);
    }
}
```
You will also need to add `RAW_ENABLE = yes` to your `rules.mk`.

The python script `hid_sender.pyw` can then be used to send arbitrary data to your keyboard which you can program to do anything.

You will also need to know how to compile and flash your keyboard firmware so that these changes can take effect.

# Usage
- Make sure to go through the project setup
- Make sure you've flashed your keyboard firmware so it's listening for data sent via hid.
- Run the autohotkey script `focuspocus.ahk`
- Right click the autohotkey icon in the system tray
- Select "Add application (F3)" from the menu
- Focus into the application you want to add
- Press F3
- An input box will appear with a label describing the window being added. You can either press OK and that aforementioned label
  will be added to the list of strings to check from when deciding to switch layers, or you can add your own string in the input
  box. Usually it will be better to add your own since the window titles can be too specific sometimes. Try and keep the name generic.
- Once the app has been added, your layers should be switching automatically whenever you gain or lose focus from the application.
