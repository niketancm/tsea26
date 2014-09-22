#include <stdio.h>
#include <stdlib.h>


void errorcheck(int val)
{
  if(val < 0){
    perror("Error while writing to sample fp");
    exit(1);
  }
}

void writeriff_header(FILE *fp)
{
  unsigned int size;
  errorcheck(fprintf(fp,"RIFF"));

  size = 0;
  errorcheck(fwrite(&size,4,1,fp)); /* Need to patch this later */
  errorcheck(fprintf(fp,"WAVE"));
}

void writefmt_header(FILE *fp,unsigned int freq)
{
  unsigned int tmp32;
  unsigned short tmp16;

  errorcheck(fprintf(fp,"fmt ")); /* Subchunk1ID */

  tmp32 = 16; /* Subchunk1Size */
  errorcheck(fwrite(&tmp32,4,1,fp));
  
  tmp16 = 1; /* AudioFormat */
  errorcheck(fwrite(&tmp16,2,1,fp));
  
  tmp16 = 2; /* NumChannels */
  errorcheck(fwrite(&tmp16,2,1,fp));

  errorcheck(fwrite(&freq,4,1,fp)); /*SampleRate */
  
  tmp32 = freq*2*2; /* ByteRate */
  errorcheck(fwrite(&tmp32,4,1,fp));

  tmp16 = 2*2; /*BlockAlign */
  errorcheck(fwrite(&tmp16,2,1,fp));

  tmp16 = 16; /* BitsPerSample */
  errorcheck(fwrite(&tmp16,2,1,fp));
}

void writedata_header(FILE *fp)
{
  unsigned int tmp32;
  errorcheck(fprintf(fp,"data"));
  
  tmp32 = 0;
  errorcheck(fwrite(&tmp32,4,1,fp));
}

int writewave(FILE *wavefp,FILE *samplefp)
{
  unsigned int samples = 0;
  unsigned short val;
  char buf[32];

  while(fgets(buf,30,samplefp)){
    val = strtoul(buf,NULL,16);
    errorcheck(fwrite(&val,2,1,wavefp)); /* Write left/right sample */
    samples += 1;
  }
  fflush(wavefp);
  
  return samples;
}
void patchheaders(FILE *fp,unsigned int samples)
{
  unsigned int tmp32;
  errorcheck(fseek(fp,4,SEEK_SET));
  
  tmp32 = samples*2 + 36;
  errorcheck(fwrite(&tmp32,4,1,fp));

  errorcheck(fseek(fp,40,SEEK_SET));
  tmp32 = samples*2;

  errorcheck(fwrite(&tmp32,4,1,fp));
  
}
int main(int argc,char **argv)
{
  FILE *samplefp;
  FILE *wavefp;

  int freq;
  unsigned int samples;

  if((sizeof(unsigned int) != 4) || (sizeof(unsigned short) != 2)){
    fprintf(stderr,"INTERNAL ERROR\n");
    exit(1);
  }

  if(argc != 4){
    fprintf(stderr,"Usage: convertsamples <samplefile> <wavefile> <frequency>\n");
    fprintf(stderr, 
	    "       Converts the samples in samplefile to a WAV format file\n"
	    "       with the specified sampling frequency\n");
    exit(1);
  }


  freq = atoi(argv[3]);

  samplefp = fopen(argv[1],"r");
  if(!samplefp) {
    perror("Opening sample file\n");
    exit(1);
  }

  wavefp = fopen(argv[2],"w");
  if(!samplefp) {
    perror("Opening wave file\n");
    exit(1);
  }
  
  writeriff_header(wavefp);
  writefmt_header(wavefp,freq);
  writedata_header(wavefp);

  samples = writewave(wavefp,samplefp);

  patchheaders(wavefp,samples);
  fclose(wavefp);
  fclose(samplefp);
  return 0;
}

/* FIXME This program will only work on little endian machines! */

