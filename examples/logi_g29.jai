main :: () {
    connect_hid_device();
}

connect_hid_device :: () -> *hid_device {
	MAX_STR :: 255;

	buf: [256] u8;
	wstr: [MAX_STR] s16;
	handle: *hid_device;
	
	res := hid_init();

    handle = hid_open(0x46D, 0xC24F, null);
	if (!handle) {
		log_error("Unable to open device\n");
		hid_exit();
 		return null;
	}

	res = hid_get_manufacturer_string(handle, wstr.data, MAX_STR);
    if (res != 0) {
        log_error("Failed to get manufacturer! Return: % ; hid error: %\n", res, hid_error(handle));
        hid_exit();
        return null;
    }

	manufact, ok := wide_to_utf8(xx wstr.data);
	memset(wstr.data, 0, size_of(type_of(wstr)));
	if ok print("Manufacturer String: %\n", manufact);

	res = hid_get_product_string(handle, wstr.data, MAX_STR);
    if (res != 0) {
        log_error("Failed to get product! hid error: %\n", hid_error(handle));
        hid_exit();
        return null;
    }

	prodname, ok= := wide_to_utf8(xx wstr.data);
	memset(wstr.data, 0, size_of(type_of(wstr)));
	if ok print("prodname: %\n", prodname);

	info := hid_get_device_info(handle);
	if (info == null) {
		log_error("Unable to get device info\n");
	} else {
		// print_devices(info);
	}

	log(">%\n", info.*);

    // res = set_wheel_leds(handle, 0);
    // if (res < 0) return NULL;
    return handle;
}

#import,file "../module.jai";

#import "Windows_Utf8";
#import "Command_Line";
#import "Basic";
