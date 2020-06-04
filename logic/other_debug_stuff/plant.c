# include <stdlib.h>
# include <stdio.h>
# include <math.h>

# include "rkf45.h"

#include <stdio.h>
#include <stdlib.h>
#include "plant.h"

#define FIXED_POINT_FRACTIONAL_BITS 8
typedef short fixed_point_t;

inline fixed_point_t float_to_fixed(double input)
{
    return (fixed_point_t)(round(input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

inline double fixed_to_float(fixed_point_t input)
{
    return ((double)input / (double)(1 << FIXED_POINT_FRACTIONAL_BITS));
}


/*
void emptyFile()
{
	   int num;
	   FILE *fptr;

	   fptr = fopen("./data.txt","w");
	   if(fptr == NULL)
	   {
	      printf("Error!");
	      exit(1);
	   }

	   fprintf(fptr,"%s","");
	   fclose(fptr);
	   return 0;
}



void appendToFile(float _time,float _val)
{

   int num;
   FILE *fptr;
   // use appropriate location if you are using MacOS or Linux
   fptr = fopen("./data.txt","a");
   if(fptr == NULL)
   {
      printf("Error!");
      exit(1);
   }

   fprintf(fptr,"%f %f\n",_time,_val);
   fclose(fptr);
   return 0;
}
*/



# define NEQN 2

  float abserr;
  int flag= 1;

  float relerr;
  float t = 0.0;
  float t_out = 0.0;
  float t_start= 0.0;
  float t_stop= 0.0;
  float y[NEQN];
  float yp[NEQN];

  float t_step = 0.001;

  float  force = 0.0;
  float mass = 1;


void r4_f1 ( float t, float y[], float yp[] )
{
	yp[0] = y[1];
    yp[1] = force;

    return;
}

void init(void)
{
	 //emptyFile();
	  y[1] = 0.0;
	  y[2] = 0.0;
	  t = 0;
}

float step (int _step, int _force )
{
	force = _force;

	float  timeStep = (float)_step * t_step;

	abserr = sqrt ( r4_epsilon ( ) );
	relerr = sqrt ( r4_epsilon ( ) );

	r4_f1 ( t, y, yp );

    t_out = t + timeStep;

    //printf("%4f,%4f,%4f,%4f,%4f\n" , y[0], yp[0],t,t_out ,force );
    flag = r4_rkf45 ( r4_f1, NEQN, y, yp, &t, t_out, &relerr, abserr, flag );
    if (flag == 7)
    {

    	flag = 2;
    }
    //t += timeStep;

   // appendToFile(t,y[0]);
  return (float)(y[0]);
}

int  main()
{
	init();
	for (int i =0;i <5; i++)
	{
		printf( "iteration:%f ,%f\n", t, step (10000,1));
	}
	return 1;
}

