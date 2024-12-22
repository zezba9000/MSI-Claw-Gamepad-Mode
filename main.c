#include <linux/types.h>
#include <linux/input.h>
#include <linux/hidraw.h>

// Ugly hack to work around failing compilation on systems that don't yet populate new version of hidraw.h to userspace
#ifndef HIDIOCSFEATURE
#warning Please have your distro update the userspace kernel headers
#define HIDIOCSFEATURE(len)    _IOC(_IOC_WRITE|_IOC_READ, 'H', 0x06, len)
#define HIDIOCGFEATURE(len)    _IOC(_IOC_WRITE|_IOC_READ, 'H', 0x07, len)
#endif

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include <linux/usbdevice_fs.h>

const char* bus_str(int bus)
{
	switch (bus) {
	case BUS_USB:
		return "USB";
		break;
	case BUS_HIL:
		return "HIL";
		break;
	case BUS_BLUETOOTH:
		return "Bluetooth";
		break;
	case BUS_VIRTUAL:
		return "Virtual";
		break;
	default:
		return "Other";
		break;
	}
}

void WriteHID(char* devicePath)
{
	int i, result;
	char buf[256];
	memset(buf, 0x0, sizeof(buf));

	// Open the Device with non-blocking
	int fd = open(devicePath, O_RDWR | O_NONBLOCK);
	if (fd < 0)
	{
		//perror("Unable to open device");
		return;
	}

	// Get Info
	struct hidraw_devinfo info;
	memset(&info, 0x0, sizeof(info));
	result = ioctl(fd, HIDIOCGRAWINFO, &info);
	if (result < 0)
	{
		perror("Failed: HIDIOCGRAWINFO");
		goto DISPOSE;
	}
	else
	{
		// validate vendor & produce IDs
		if (info.vendor != 0x0bd0 && info.product != 0x1901) goto DISPOSE;
		printf("Found Gamepad HID device");
		printf("\tbustype: %d (%s)\n", info.bustype, bus_str(info.bustype));
		printf("\tvendor: 0x%04hx\n", info.vendor);
		printf("\tproduct: 0x%04hx\n", info.product);
	}

	// Get Report Descriptor Size
	int desc_size = 0;
	result = ioctl(fd, HIDIOCGRDESCSIZE, &desc_size);
	if (result < 0)
	{
		desc_size = 0;
		perror("Failed: HIDIOCGRDESCSIZE");
		//goto DISPOSE;
	}
	else
	{
		printf("Report Descriptor Size: %d\n", desc_size);
	}

	// Get Report Descriptor
	if (desc_size > 0)
	{
		struct hidraw_report_descriptor rpt_desc;
		memset(&rpt_desc, 0x0, sizeof(rpt_desc));
		rpt_desc.size = desc_size;
		result = ioctl(fd, HIDIOCGRDESC, &rpt_desc);
		if (result < 0)
		{
			perror("Failed: HIDIOCGRDESC");
			//goto DISPOSE;
		}
		else
		{
			printf("Report Descriptor:\n");
			for (i = 0; i < rpt_desc.size; i++) printf("%hhx ", rpt_desc.value[i]);
			puts("\n");
		}
	}

	// Get Name
	result = ioctl(fd, HIDIOCGRAWNAME(256), buf);
	if (result < 0)
	{
		perror("Failed: HIDIOCGRAWNAME");
		//goto DISPOSE;
	}
	else
	{
		printf("Raw Name: %s\n", buf);
	}

	// Get Physical Location
	result = ioctl(fd, HIDIOCGRAWPHYS(256), buf);
	if (result < 0)
	{
		perror("Failed: HIDIOCGRAWPHYS");
		//goto DISPOSE;
	}
	else
	{
		printf("Raw Phys: %s\n", buf);
	}

	// send xpad mode change Report to the Device
	memset(buf, 0x0, sizeof(buf));
	i = 0;
	buf[i++] = 15;// report id
	buf[i++] = 0;
	buf[i++] = 0;
	buf[i++] = 60;
	buf[i++] = 36;// we want to switch mode
	buf[i++] = 1;// xpad mode
	buf[i++] = 0;
	buf[i++] = 0;
	
	printf("Sending %d bytes...\n", i);
	result = write(fd, buf, i);
	if (result < 0)
	{
		printf("Write mode failed: %d\n", errno);
	}
	else
	{
		printf("Xpad mode set: write() wrote %d bytes\n", result);
	}

	/*// Get a report from the device
	sleep(1);
	result = read(fd, buf, 256);
	if (result < 0)
	{
		perror("Read mode response failed");
	}
	else
	{
		printf("Response read %d bytes:\n\t", result);
		for (i = 0; i < result; i++) printf("%hhx ", buf[i]);
		puts("\n");
	}*/

	DISPOSE:;
	close(fd);
}

int main(int argc, char **argv)
{
	for (int i = 0; i != 20; ++i)
	{
		char devicePath[64];
		memset(devicePath, 0x0, sizeof(devicePath));
		snprintf(devicePath, sizeof(devicePath), "/dev/hidraw%d", i);
		WriteHID(devicePath);
	}
}
