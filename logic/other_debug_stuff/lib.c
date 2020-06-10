# include <stdlib.h>
# include <stdio.h>
# include <math.h>


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
}


void logToFile(float _time, float _value )
{
	printf("acctual  parameters %d %f \n",_time, _value);
    appendToFile(_time, _value);
}

