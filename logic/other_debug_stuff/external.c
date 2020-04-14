#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <linux/ioctl.h>
#include <sys/stat.h>
#include <sys/poll.h>
#include <fcntl.h>
#include <errno.h>

#include "lib.h"

void logData( int _time, int _value )
{
	logToFile(_time, _value);
}

void initFile(int _dummy)
{
	emptyFile();
}

