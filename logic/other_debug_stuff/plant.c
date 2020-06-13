# include <stdlib.h>
# include <stdio.h>
# include <math.h>

# include "rkf45.h"

#include <stdio.h>
#include <stdlib.h>
#include "plant.h"
#include "lib.h"






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

  float  voltage = 0.0;

  float Kt = 0.000458;//4.5877e-04;
  float J  = 0.00000289;//2.8966e-06;
  float L =  0.0000152;//1.5278e-05;
  float R =  0.53;
  float Ke =  0.000528;//5.2877e-04;

void r4_f1 ( float t, float y[], float yp[] )
{


	yp[0] = (Kt*y[1])/J;
    yp[1] = (voltage - R*y[1] - Ke*y[0])/L;

    return;
}

void init(void)
{
	  emptyFile();
	  y[1] = 0.0;
	  y[2] = 0.0;
	  t = 0;
}

float step (int _step, float _force )
{
	voltage = _force;

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
    printf("log %f %f %f\n",t,voltage,y[0]);
    logToFile(t,y[0]);
  return (float)(y[0]);
}
/*
int  main()
{
	init();
	for (int i =0;i <50; i++)
	{
		printf( "iteration:%f ,%f\n", t, step (1000,1));
	}
	return 1;
}
*/
