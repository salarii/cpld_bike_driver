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
#include <math.h>

#include "lib.h"
#include "plant.h"


#define FIXED_POINT_FRACTIONAL_BITS 8
typedef short fixed_point_t;

fixed_point_t float_to_fixed(double input)
{
    return (fixed_point_t)(round(input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

double fixed_to_float(fixed_point_t input)
{
    return ((double)input / (double)(1 << FIXED_POINT_FRACTIONAL_BITS));
}

void logData( int _time, int _value )
{
	logToFile(_time, _value);
}

void initFile(int _dummy)
{
	emptyFile();
}

void initPlant(int _dummy)
{
	emptyFile();
	init();
}

int regToPlant (int _time, int _force )
{
	//float adjusted = fixed_to_float(_force );



	 float  temp = step(_time,(float)_force );
	 return temp;
	 // printf("%4f\n",temp);
	// return -0.0002 * pow(temp,3) + 0.0695*pow(temp,2) -1.1323 *temp + 38.5540;;

}
