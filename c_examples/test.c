#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	int i, j;
	int width = 16, height = 16;

	printf("width %d\n", width);
	printf("height %d\n", height);
	printf("allocated: %d\n", width*height*4);

	unsigned char *thing = (unsigned char *)malloc(width*height*4);
	unsigned char *p=thing;

	// for(i=0; i<=width; i++)
    // {
    //     for(j=0; j<=height; j++)
    //     {
        	*p++=rand()%256;
        	*p++=rand()%256;
        	*p++=rand()%256;
        // }
        *p++;
    // }

    // for (i=0; i < width*height*4; i++)
	//     printf("%d\n", thing[i]);

	return 0;
}