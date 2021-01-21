#include <stdio.h>
#include <stdlib.h>

int main()
{
	unsigned char input_file[10];
	FILE *fp;

	//printf ("Enter input file name: ");
	//scanf ("%s", &input_file);

	fp = fopen ("data1.in", "r");
	if (fp == NULL)
	{
		printf ("File read error");
		exit(0);
	}

	unsigned long int x_temp, x_bar_temp, x[1000], x_bar[1000];

	int i = 0;
	fp = fopen (input_file, "r");
	while (!feof(fp))
	{
		fscanf (fp, "%x", &x_temp);
		x_bar_temp = (((~x_temp + 1)));				//Converting to 2's complement


		//Sign Extension for original data
		x_temp = x_temp << 16;
		if(x_temp & 0x0000000080000000)
			x_temp = x_temp | 0xFFFFFFFF00000000;
		else
			x_temp = x_temp & 0x00000000FFFFFFFF;

		//Sign Extension for 2's Complement
		x_bar_temp = x_bar_temp << 16;
		if(x_bar_temp & 0x0000000080000000)
			x_bar_temp = x_bar_temp | 0xFFFFFFFF00000000;
		else
			x_bar_temp = x_bar_temp & 0x00000000FFFFFFFF;

		x[i] = x_temp;
		x_bar[i] = x_bar_temp;
		i++;
	}

	//Coefficient Lookup Table processing
	int j = 0;
	FILE *fp1, *fp2;
	unsigned char coeff_file[10];
	unsigned char rj_file[10];
	unsigned int h_temp, coeff_arr[200];
	unsigned int rj_arr[20], rj_temp;

	fp1 = fopen ("Coeff1.txt", "r");
	if (fp1 == NULL)
	{
		printf ("File read error");
		exit(0);
	}

	i = 0;
	fp1 = fopen (coeff_file, "r");
	while (!feof(fp1))
	{
		fscanf (fp1, "%x", &h_temp);
		coeff_arr[i] = h_temp;
		i++;
	}

	//RJ Table processing
	i = 0;
	fp2 = fopen ("Rj1.txt", "r");
	if (fp2 == NULL)
	{
		printf ("File read error");
		exit(0);
	}

	while (!feof(fp2))
	{
		fscanf (fp1, "%x", &rj_temp);
		rj_arr[i] = rj_temp;
		i++;
	}

	//Output calculation
	int k = 0;
	int coeff_pos = 0;
	unsigned int h_val = 0;
	unsigned long int u_arr[16], u_temp = 0, output[512], y_temp = 0;

	for (i=0; i<16; i++)
		u_arr[i] = 0;

	for (i=0; i<512; i++)
	{
		output[i] = 0;
		coeff_pos = 0;
		for (j=0; j<16; j++)
		{
        unsigned int rj_val = rj_arr[j];
			u_temp = 0;
			y_temp = 0;
			for (k=0; k<rj_val; k++)
			{
				h_val =  coeff_arr[coeff_pos++];
			unsigned int	x_index = h_val & 0x000000FF;
				if (i-x_index > 0)
				{
					if (h_val & 0x00000100)
						u_temp = u_temp + x_bar[i-x_index];
					else
						u_temp = u_temp + x[i-x_index];
				}
			}
			y_temp = ((y_temp + u_temp) >> 1);
		}
		output[i] = y_temp;
		printf ("%d.%010llX\n", i, output[i]);
	}
}
