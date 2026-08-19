//
// This file was auto-generated using the following command:
//
// jai ./generate.jai
//



HID_API_VERSION_MAJOR :: 0;

HID_API_VERSION_MINOR :: 15;

HID_API_VERSION_PATCH :: 0;

HID_API_MAX_REPORT_DESCRIPTOR_SIZE :: 4096;

/** A structure to hold the version numbers. */
hid_api_version :: struct {
    major: s32; /**< major version number */
    minor: s32; /**< minor version number */
    patch: s32; /**< patch version number */
}

hid_device_ :: struct {}
hid_device :: hid_device_;

/** @brief HID underlying bus types.

@ingroup API
*/
hid_bus_type :: enum s32 {
    UNKNOWN   :: 0;

    USB       :: 1;

    BLUETOOTH :: 2;

    I2C       :: 3;

    SPI       :: 4;

    HID_API_BUS_UNKNOWN   :: UNKNOWN;

    HID_API_BUS_USB       :: USB;

    HID_API_BUS_BLUETOOTH :: BLUETOOTH;

    HID_API_BUS_I2C       :: I2C;

    HID_API_BUS_SPI       :: SPI;
}

/** hidapi info structure */
hid_device_info :: struct {
    /** Platform-specific device path */
    path:                *u8;

    /** Device Vendor ID */
    vendor_id:           u16;

    /** Device Product ID */
    product_id:          u16;

    /** Serial Number */
    serial_number:       *s16;

    /** Device Release Number in binary-coded decimal,
    also known as Device Version Number */
    release_number:      u16;

    /** Manufacturer String */
    manufacturer_string: *s16;

    /** Product string */
    product_string:      *s16;

    /** Usage Page for this Device/Interface
    (Windows/Mac/hidraw only) */
    usage_page:          u16;

    /** Usage for this Device/Interface
    (Windows/Mac/hidraw only) */
    usage:               u16;

    /** The USB interface which this logical device
    represents.
    
    Valid only if the device is a USB HID device.
    Set to -1 in all other cases.
    */
    interface_number:    s32;

    /** Pointer to the next device */
    next:                *hid_device_info;

    /** Underlying bus type
    Since version 0.13.0, @ref HID_API_VERSION >= HID_API_MAKE_VERSION(0, 13, 0)
    */
    bus_type:            hid_bus_type;
}

/** @brief Initialize the HIDAPI library.

This function initializes the HIDAPI library. Calling it is not
strictly necessary, as it will be called automatically by
hid_enumerate() and any of the hid_open_*() functions if it is
needed.  This function should be called at the beginning of
execution however, if there is a chance of HIDAPI handles
being opened by different threads simultaneously.

@ingroup API

@returns
This function returns 0 on success and -1 on error.
Call hid_error(NULL) to get the failure reason.
*/
hid_init :: () -> s32 #foreign hidapi;

/** @brief Finalize the HIDAPI library.

This function frees all of the static data associated with
HIDAPI. It should be called at the end of execution to avoid
memory leaks.

@ingroup API

@returns
This function returns 0 on success and -1 on error.
*/
hid_exit :: () -> s32 #foreign hidapi;

/** @brief Enumerate the HID Devices.

This function returns a linked list of all the HID devices
attached to the system which match vendor_id and product_id.
If @p vendor_id is set to 0 then any vendor matches.
If @p product_id is set to 0 then any product matches.
If @p vendor_id and @p product_id are both set to 0, then
all HID devices will be returned.

@ingroup API
@param vendor_id The Vendor ID (VID) of the types of device
to open.
@param product_id The Product ID (PID) of the types of
device to open.

@returns
This function returns a pointer to a linked list of type
struct #hid_device_info, containing information about the HID devices
attached to the system,
or NULL in the case of failure or if no HID devices present in the system.
Call hid_error(NULL) to get the failure reason.

@note The returned value by this function must to be freed by calling hid_free_enumeration(),
when not needed anymore.
*/
hid_enumerate :: (vendor_id: u16, product_id: u16) -> *hid_device_info #foreign hidapi;

/** @brief Free an enumeration Linked List

This function frees a linked list created by hid_enumerate().

@ingroup API
@param devs Pointer to a list of struct_device returned from
hid_enumerate().
*/
hid_free_enumeration :: (devs: *hid_device_info) -> void #foreign hidapi;

/** @brief Open a HID device using a Vendor ID (VID), Product ID
(PID) and optionally a serial number.

If @p serial_number is NULL, the first device with the
specified VID and PID is opened.

@ingroup API
@param vendor_id The Vendor ID (VID) of the device to open.
@param product_id The Product ID (PID) of the device to open.
@param serial_number The Serial Number of the device to open
(Optionally NULL).

@returns
This function returns a pointer to a #hid_device object on
success or NULL on failure.
Call hid_error(NULL) to get the failure reason.

@note The returned object must be freed by calling hid_close(),
when not needed anymore.
*/
hid_open :: (vendor_id: u16, product_id: u16, serial_number: *s16) -> *hid_device #foreign hidapi;

/** @brief Open a HID device by its path name.

The path name be determined by calling hid_enumerate(), or a
platform-specific path name can be used (eg: /dev/hidraw0 on
Linux).

@ingroup API
@param path The path name of the device to open

@returns
This function returns a pointer to a #hid_device object on
success or NULL on failure.
Call hid_error(NULL) to get the failure reason.

@note The returned object must be freed by calling hid_close(),
when not needed anymore.
*/
hid_open_path :: (path: *u8) -> *hid_device #foreign hidapi;

/** @brief Write an Output report to a HID device.

The first byte of @p data[] must contain the Report ID. For
devices which only support a single report, this must be set
to 0x0. The remaining bytes contain the report data. Since
the Report ID is mandatory, calls to hid_write() will always
contain one more byte than the report contains. For example,
if a hid report is 16 bytes long, 17 bytes must be passed to
hid_write(), the Report ID (or 0x0, for devices with a
single report), followed by the report data (16 bytes). In
this example, the length passed in would be 17.

hid_write() will send the data on the first interrupt OUT
endpoint, if one exists. If it does not the behaviour is as
@ref hid_send_output_report

@ingroup API
@param dev A device handle returned from hid_open().
@param data The data to send, including the report number as
the first byte.
@param length The length in bytes of the data to send.

@returns
This function returns the actual number of bytes written and
-1 on error.
Call hid_error(dev) to get the failure reason.
*/
hid_write :: (dev: *hid_device, data: *u8, length: u64) -> s32 #foreign hidapi;

/** @brief Read an Input report from a HID device with timeout.

Input reports are returned
to the host through the INTERRUPT IN endpoint. The first byte will
contain the Report number if the device uses numbered reports.

@ingroup API
@param dev A device handle returned from hid_open().
@param data A buffer to put the read data into.
@param length The number of bytes to read. For devices with
multiple reports, make sure to read an extra byte for
the report number.
@param milliseconds timeout in milliseconds or -1 for blocking wait.

@returns
This function returns the actual number of bytes read and
-1 on error.
Call hid_read_error(dev) to get the failure reason.
If no packet was available to be read within
the timeout period, this function returns 0.

@note This function doesn't change the buffer returned by the hid_error(dev).
*/
hid_read_timeout :: (dev: *hid_device, data: *u8, length: u64, milliseconds: s32) -> s32 #foreign hidapi;

/** @brief Read an Input report from a HID device.

Input reports are returned
to the host through the INTERRUPT IN endpoint. The first byte will
contain the Report number if the device uses numbered reports.

@ingroup API
@param dev A device handle returned from hid_open().
@param data A buffer to put the read data into.
@param length The number of bytes to read. For devices with
multiple reports, make sure to read an extra byte for
the report number.

@returns
This function returns the actual number of bytes read and
-1 on error.
Call hid_read_error(dev) to get the failure reason.
If no packet was available to be read and
the handle is in non-blocking mode, this function returns 0.

@note This function doesn't change the buffer returned by the hid_error(dev).
*/
hid_read :: (dev: *hid_device, data: *u8, length: u64) -> s32 #foreign hidapi;

/** @brief Get a string describing the last error which occurred during hid_read/hid_read_timeout.

Since version 0.15.0, @ref HID_API_VERSION >= HID_API_MAKE_VERSION(0, 15, 0)

This function is intended for logging/debugging purposes.

This function guarantees to never return NULL for a valid @ref dev.
If there was no error in the last call to hid_read/hid_read_error -
the returned string clearly indicates that.

Strings returned from hid_read_error() must not be freed by the user,
i.e. owned by HIDAPI library.
Device-specific error string may remain allocated at most until hid_close() is called.

@ingroup API
@param dev A device handle. Shall never be NULL.

@returns
A string describing the hid_read/hid_read_timeout error (if any).
*/
hid_read_error :: (dev: *hid_device) -> *s16 #foreign hidapi;

/** @brief Set the device handle to be non-blocking.

In non-blocking mode calls to hid_read() will return
immediately with a value of 0 if there is no data to be
read. In blocking mode, hid_read() will wait (block) until
there is data to read before returning.

Nonblocking can be turned on and off at any time.

@ingroup API
@param dev A device handle returned from hid_open().
@param nonblock enable or not the nonblocking reads
- 1 to enable nonblocking
- 0 to disable nonblocking.

@returns
This function returns 0 on success and -1 on error.
Call hid_error(dev) to get the failure reason.
*/
hid_set_nonblocking :: (dev: *hid_device, nonblock: s32) -> s32 #foreign hidapi;

/** @brief Send a Feature report to the device.

Feature reports are sent over the Control endpoint as a
Set_Report transfer.  The first byte of @p data[] must
contain the Report ID. For devices which only support a
single report, this must be set to 0x0. The remaining bytes
contain the report data. Since the Report ID is mandatory,
calls to hid_send_feature_report() will always contain one
more byte than the report contains. For example, if a hid
report is 16 bytes long, 17 bytes must be passed to
hid_send_feature_report(): the Report ID (or 0x0, for
devices which do not use numbered reports), followed by the
report data (16 bytes). In this example, the length passed
in would be 17.

@ingroup API
@param dev A device handle returned from hid_open().
@param data The data to send, including the report number as
the first byte.
@param length The length in bytes of the data to send, including
the report number.

@returns
This function returns the actual number of bytes written and
-1 on error.
Call hid_error(dev) to get the failure reason.
*/
hid_send_feature_report :: (dev: *hid_device, data: *u8, length: u64) -> s32 #foreign hidapi;

/** @brief Get a feature report from a HID device.

Set the first byte of @p data[] to the Report ID of the
report to be read.  Make sure to allow space for this
extra byte in @p data[]. Upon return, the first byte will
still contain the Report ID, and the report data will
start in data[1].

@ingroup API
@param dev A device handle returned from hid_open().
@param data A buffer to put the read data into, including
the Report ID. Set the first byte of @p data[] to the
Report ID of the report to be read, or set it to zero
if your device does not use numbered reports.
@param length The number of bytes to read, including an
extra byte for the report ID. The buffer can be longer
than the actual report.

@returns
This function returns the number of bytes read plus
one for the report ID (which is still in the first
byte), or -1 on error.
Call hid_error(dev) to get the failure reason.
*/
hid_get_feature_report :: (dev: *hid_device, data: *u8, length: u64) -> s32 #foreign hidapi;

/** @brief Send a Output report to the device.

Since version 0.15.0, @ref HID_API_VERSION >= HID_API_MAKE_VERSION(0, 15, 0)

Output reports are sent over the Control endpoint as a
Set_Report transfer.  The first byte of @p data[] must
contain the Report ID. For devices which only support a
single report, this must be set to 0x0. The remaining bytes
contain the report data. Since the Report ID is mandatory,
calls to hid_send_output_report() will always contain one
more byte than the report contains. For example, if a hid
report is 16 bytes long, 17 bytes must be passed to
hid_send_output_report(): the Report ID (or 0x0, for
devices which do not use numbered reports), followed by the
report data (16 bytes). In this example, the length passed
in would be 17.

This function sets the return value of hid_error().

@ingroup API
@param dev A device handle returned from hid_open().
@param data The data to send, including the report number as
the first byte.
@param length The length in bytes of the data to send, including
the report number.

@returns
This function returns the actual number of bytes written and
-1 on error.

@see @ref hid_write
*/
hid_send_output_report :: (dev: *hid_device, data: *u8, length: u64) -> s32 #foreign hidapi;

/** @brief Get a input report from a HID device.

Since version 0.10.0, @ref HID_API_VERSION >= HID_API_MAKE_VERSION(0, 10, 0)

Set the first byte of @p data[] to the Report ID of the
report to be read. Make sure to allow space for this
extra byte in @p data[]. Upon return, the first byte will
still contain the Report ID, and the report data will
start in data[1].

@ingroup API
@param dev A device handle returned from hid_open().
@param data A buffer to put the read data into, including
the Report ID. Set the first byte of @p data[] to the
Report ID of the report to be read, or set it to zero
if your device does not use numbered reports.
@param length The number of bytes to read, including an
extra byte for the report ID. The buffer can be longer
than the actual report.

@returns
This function returns the number of bytes read plus
one for the report ID (which is still in the first
byte), or -1 on error.
Call hid_error(dev) to get the failure reason.
*/
hid_get_input_report :: (dev: *hid_device, data: *u8, length: u64) -> s32 #foreign hidapi;

/** @brief Close a HID device.

@ingroup API
@param dev A device handle returned from hid_open().
*/
hid_close :: (dev: *hid_device) -> void #foreign hidapi;

/** @brief Get The Manufacturer String from a HID device.

@ingroup API
@param dev A device handle returned from hid_open().
@param string A wide string buffer to put the data into.
@param maxlen The length of the buffer in multiples of wchar_t.

@returns
This function returns 0 on success and -1 on error.
Call hid_error(dev) to get the failure reason.
*/
hid_get_manufacturer_string :: (dev: *hid_device, _string: *s16, maxlen: u64) -> s32 #foreign hidapi;

/** @brief Get The Product String from a HID device.

@ingroup API
@param dev A device handle returned from hid_open().
@param string A wide string buffer to put the data into.
@param maxlen The length of the buffer in multiples of wchar_t.

@returns
This function returns 0 on success and -1 on error.
Call hid_error(dev) to get the failure reason.
*/
hid_get_product_string :: (dev: *hid_device, _string: *s16, maxlen: u64) -> s32 #foreign hidapi;

/** @brief Get The Serial Number String from a HID device.

@ingroup API
@param dev A device handle returned from hid_open().
@param string A wide string buffer to put the data into.
@param maxlen The length of the buffer in multiples of wchar_t.

@returns
This function returns 0 on success and -1 on error.
Call hid_error(dev) to get the failure reason.
*/
hid_get_serial_number_string :: (dev: *hid_device, _string: *s16, maxlen: u64) -> s32 #foreign hidapi;

/** @brief Get The struct #hid_device_info from a HID device.

Since version 0.13.0, @ref HID_API_VERSION >= HID_API_MAKE_VERSION(0, 13, 0)

@ingroup API
@param dev A device handle returned from hid_open().

@returns
This function returns a pointer to the struct #hid_device_info
for this hid_device, or NULL in the case of failure.
Call hid_error(dev) to get the failure reason.
This struct is valid until the device is closed with hid_close().

@note The returned object is owned by the @p dev, and SHOULD NOT be freed by the user.
*/
hid_get_device_info :: (dev: *hid_device) -> *hid_device_info #foreign hidapi;

/** @brief Get a string from a HID device, based on its string index.

@ingroup API
@param dev A device handle returned from hid_open().
@param string_index The index of the string to get.
@param string A wide string buffer to put the data into.
@param maxlen The length of the buffer in multiples of wchar_t.

@returns
This function returns 0 on success and -1 on error.
Call hid_error(dev) to get the failure reason.
*/
hid_get_indexed_string :: (dev: *hid_device, string_index: s32, _string: *s16, maxlen: u64) -> s32 #foreign hidapi;

/** @brief Get a report descriptor from a HID device.

Since version 0.14.0, @ref HID_API_VERSION >= HID_API_MAKE_VERSION(0, 14, 0)

User has to provide a preallocated buffer where descriptor will be copied to.
The recommended size for preallocated buffer is @ref HID_API_MAX_REPORT_DESCRIPTOR_SIZE bytes.

@ingroup API
@param dev A device handle returned from hid_open().
@param buf The buffer to copy descriptor into.
@param buf_size The size of the buffer in bytes.

@returns
This function returns non-negative number of bytes actually copied, or -1 on error.
*/
hid_get_report_descriptor :: (dev: *hid_device, buf: *u8, buf_size: u64) -> s32 #foreign hidapi;

/** @brief Get a string describing the last error which occurred.

This function is intended for logging/debugging purposes.

This function guarantees to never return NULL.
If there was no error in the last function call -
the returned string clearly indicates that.

Any HIDAPI function that can explicitly indicate an execution failure
(e.g. by an error code, or by returning NULL) - may set the error string,
to be returned by this function.

Strings returned from hid_error() must not be freed by the user,
i.e. owned by HIDAPI library.
Device-specific error string may remain allocated at most until hid_close() is called.
Global error string may remain allocated at most until hid_exit() is called.

@ingroup API
@param dev A device handle returned from hid_open(),
or NULL to get the last non-device-specific error
(e.g. for errors in hid_open() or hid_enumerate()).

@returns
A string describing the last error (if any).
*/
hid_error :: (dev: *hid_device) -> *s16 #foreign hidapi;

/** @brief Get a runtime version of the library.

This function is thread-safe.

@ingroup API

@returns
Pointer to statically allocated struct, that contains version.
*/
hid_version :: () -> *hid_api_version #foreign hidapi;

/** @brief Get a runtime version string of the library.

This function is thread-safe.

@ingroup API

@returns
Pointer to statically allocated string, that contains version string.
*/
hid_version_str :: () -> *u8 #foreign hidapi;

/** @brief Get the container ID for a HID device.

Since version 0.12.0, @ref HID_API_VERSION >= HID_API_MAKE_VERSION(0, 12, 0)

This function returns the `DEVPKEY_Device_ContainerId` property of
the given device. This can be used to correlate different
interfaces/ports on the same hardware device.

@ingroup API
@param dev A device handle returned from hid_open().
@param container_id The device's container ID on return.

@returns
This function returns 0 on success and -1 on error.
*/
hid_winapi_get_container_id :: (dev: *hid_device, container_id: *GUID) -> s32 #foreign hidapi;

/**
* @brief Reconstructs a HID Report Descriptor from a Win32 HIDP_PREPARSED_DATA structure.
*  This reconstructed report descriptor is logical identical to the real report descriptor,
*  but not byte wise identical.
*
* @param[in]  hidp_preparsed_data Pointer to the HIDP_PREPARSED_DATA to read, i.e.: the value of PHIDP_PREPARSED_DATA,
*   as returned by HidD_GetPreparsedData WinAPI function.
* @param      buf       Pointer to the buffer where the report descriptor should be stored.
* @param[in]  buf_size  Size of the buffer. The recommended size for the buffer is @ref HID_API_MAX_REPORT_DESCRIPTOR_SIZE bytes.
*
* @return Returns size of reconstructed report descriptor if successful, -1 for error.
*/
hid_winapi_descriptor_reconstruct_pp_data :: (hidp_preparsed_data: *void, buf: *u8, buf_size: u64) -> s32 #foreign hidapi;

/**
* @brief Sets the timeout for hid_write operation.
*
* Since version 0.15.0, @ref HID_API_VERSION >= HID_API_MAKE_VERSION(0, 15, 0)
*
* The default timeout is 1sec for winapi backend.
*
* In case if 1sec is not enough, on in case of multi-platform development,
* the recommended value is 5sec, e.g. to match (unconfigurable) 5sec timeout
* set for hidraw (linux kernel) implementation.
*
* When the timeout is set to 0, hid_write function becomes non-blocking and would exit immediately.
* When the timeout is set to INFINITE ((DWORD)-1), the function will not exit,
* until the write operation is performed or an error occured.
* See dwMilliseconds parameter documentation of WaitForSingleObject function.
*
* @param timeout New timeout value in milliseconds.
*/
hid_winapi_set_write_timeout :: (dev: *hid_device, timeout: u32) -> void #foreign hidapi;

#scope_file

#import "Basic"; // For assert

hidapi :: #library,no_dll "windows/hidapi";

#run {
    {
        info := type_info(hid_api_version);
        for info.members {
            if it.name == {
                case "major";
                    assert(it.offset_in_bytes == 0, "hid_api_version.major has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "hid_api_version.major has unexpected size % instead of 4", it.type.runtime_size);
                case "minor";
                    assert(it.offset_in_bytes == 4, "hid_api_version.minor has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "hid_api_version.minor has unexpected size % instead of 4", it.type.runtime_size);
                case "patch";
                    assert(it.offset_in_bytes == 8, "hid_api_version.patch has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "hid_api_version.patch has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(hid_api_version) == 12, "hid_api_version has size % instead of 12", size_of(hid_api_version));
    }

    {
        info := type_info(hid_device_info);
        for info.members {
            if it.name == {
                case "path";
                    assert(it.offset_in_bytes == 0, "hid_device_info.path has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "hid_device_info.path has unexpected size % instead of 8", it.type.runtime_size);
                case "vendor_id";
                    assert(it.offset_in_bytes == 8, "hid_device_info.vendor_id has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 2, "hid_device_info.vendor_id has unexpected size % instead of 2", it.type.runtime_size);
                case "product_id";
                    assert(it.offset_in_bytes == 10, "hid_device_info.product_id has unexpected offset % instead of 10", it.offset_in_bytes);
                    assert(it.type.runtime_size == 2, "hid_device_info.product_id has unexpected size % instead of 2", it.type.runtime_size);
                case "serial_number";
                    assert(it.offset_in_bytes == 16, "hid_device_info.serial_number has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "hid_device_info.serial_number has unexpected size % instead of 8", it.type.runtime_size);
                case "release_number";
                    assert(it.offset_in_bytes == 24, "hid_device_info.release_number has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 2, "hid_device_info.release_number has unexpected size % instead of 2", it.type.runtime_size);
                case "manufacturer_string";
                    assert(it.offset_in_bytes == 32, "hid_device_info.manufacturer_string has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "hid_device_info.manufacturer_string has unexpected size % instead of 8", it.type.runtime_size);
                case "product_string";
                    assert(it.offset_in_bytes == 40, "hid_device_info.product_string has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "hid_device_info.product_string has unexpected size % instead of 8", it.type.runtime_size);
                case "usage_page";
                    assert(it.offset_in_bytes == 48, "hid_device_info.usage_page has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 2, "hid_device_info.usage_page has unexpected size % instead of 2", it.type.runtime_size);
                case "usage";
                    assert(it.offset_in_bytes == 50, "hid_device_info.usage has unexpected offset % instead of 50", it.offset_in_bytes);
                    assert(it.type.runtime_size == 2, "hid_device_info.usage has unexpected size % instead of 2", it.type.runtime_size);
                case "interface_number";
                    assert(it.offset_in_bytes == 52, "hid_device_info.interface_number has unexpected offset % instead of 52", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "hid_device_info.interface_number has unexpected size % instead of 4", it.type.runtime_size);
                case "next";
                    assert(it.offset_in_bytes == 56, "hid_device_info.next has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "hid_device_info.next has unexpected size % instead of 8", it.type.runtime_size);
                case "bus_type";
                    assert(it.offset_in_bytes == 64, "hid_device_info.bus_type has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "hid_device_info.bus_type has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(hid_device_info) == 72, "hid_device_info has size % instead of 72", size_of(hid_device_info));
    }
}

