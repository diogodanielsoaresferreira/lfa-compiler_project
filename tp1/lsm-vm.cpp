/*
	LFA 2016 - Grupo 3
	Projeto 1
	David Almeida, Diogo Ferreira, Francisco Cunha, José Castanheira
	Máquina Virtual
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <getopt.h>
#include <string.h>
#include <math.h>

#include <iostream>

#include <stack>
#include <map>

class LSMVM
{
public:
    std::stack<uint32_t> ds;
    std::stack<uint32_t> cs;
    uint16_t ip = 0;
    uint32_t* data = NULL;
    uint8_t* text = NULL;

    uint16_t bss_size = 0;
    uint16_t data_size = 0;
    uint16_t text_size = 0;

    bool good_ = false;
    bool debug = false;
    inline bool good() { return good_; }
    inline bool bad() { return ! good_; }

    uint32_t magic = 0;
    uint16_t major_version = 0,
             minor_version = 0;

    union {
        int32_t ivalue;
        uint32_t uivalue;
        float fvalue;
    } word;

    union {
        int8_t ivalue;
        uint8_t uivalue;
    } byte;

    LSMVM() {}
    LSMVM(const char* path);

    bool parse(const char* path);

    void reset();
    void show();
    void step();
    void run();

    uint32_t getNumber_DS();
    void alu(uint8_t);
    void other_instructions(uint8_t);
	void fpu(uint8_t);
	void jump(uint8_t);
	void dataStack(uint8_t);

};

LSMVM::LSMVM(const char* path)
{
    if ((good_ = parse(path)) == false)
    {
        reset();
    }
}

void LSMVM::step()
{
	 ip++;
     if(ip==text_size) exit(0);
}

void LSMVM::run()
{
    ip = 0;
    while (ip < text_size && text[ip] <= 0xf3)
    {
        if(debug)
            printf("\nOP: %X",text[ip]);
		if (text[ip] >= 0x10 && text[ip] <= 0x1b)
		{
			alu(text[ip]);
		}
		else if (text[ip] >= 0x20 && text[ip] <= 0x28)
		{
			fpu(text[ip]);
		}
		else if (text[ip] >= 0x30 && text[ip] <= 0x40)
		{
			jump(text[ip]);
		}
		else if (text[ip] >= 0x50 && text[ip] <= 0x69)
		{
			dataStack(text[ip]);
		}
		else if((text[ip] >= 0xf0 && text[ip] <= 0xf3) || text[ip] == 0x00)
		{
			other_instructions(text[ip]);
		}
        else{
            printf("\nA fatal error ocurred.");
            exit(1);
        }
		step();
	}
}

bool LSMVM::parse(const char* path)
{
    reset();

    /* open binary file */
    FILE* ifp = fopen(path, "r");
    if (ifp == NULL) goto parse_fail;

    /* read and check magic number */
    uint8_t m;
    for (int i = 0; i < 4; i++)
    {
        if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
        magic <<= 8;
        magic |= (m & 0xff);
    }

    /* read version */
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    major_version = (m & 0xff) << 8;
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    major_version |= (m & 0xff);
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    minor_version = (m & 0xff) << 8;
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    minor_version |= (m & 0xff);

    /* read bss size */
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    bss_size = (m & 0xff) << 8;
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    bss_size |= (m & 0xff);

    /* read data size */
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    data_size = (m & 0xff) << 8;
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    data_size |= (m & 0xff);

    /* alocate data array */
    data = new(std::nothrow) uint32_t[data_size+bss_size+1];
    memset(data+data_size, 0x0, bss_size);

    //printf("DATAS:%d",data_size);
    //printf("BSS_S:%d",bss_size);


    /* read data variables */
    for (int j = 0; j < data_size; j++)
    {   
        uint32_t v = 0;
        for (int i = 0; i < 4; i++)
        {   
            if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
            v <<=8;
            v |= (m & 0xff);
        }
        data[j] = v;
    }

    /* read text size */
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    text_size = (m & 0xff) << 8;
    if (fread(&m, 1, 1, ifp) != 1) goto parse_fail;
    text_size |= (m & 0xff);


    /* alocate text array */
    text = new(std::nothrow) uint8_t[text_size];

    /* read text instructions */
    for (int j = 0; j < text_size; j++)
    {
        if (fread(&m, 1, 1, ifp) != 1) return true;
        text[j] = m;
    }

    return true;

parse_fail:
    reset();
    return false;
}

void LSMVM::reset()
{
    delete [] data;
    delete [] text;
}

void LSMVM::show()
{
    fprintf(stdout, "magic: 0x%08x\n", magic);
    fprintf(stdout, "major_version: %d\n", major_version);
    fprintf(stdout, "minor_version: %d\n", minor_version);

    fprintf(stdout, "bss_size: %d (0x%0x)\n", bss_size, bss_size);

    fprintf(stdout, "data_size: %d (0x%0x)\n", data_size, data_size);
    fprintf(stdout, "data[] = {\n");
    for (int j = 0; j < data_size; j++)
    {
        fprintf(stdout, "  0x%08x", data[j]);
    }
    fprintf(stdout, "\n}\n");

    fprintf(stdout, "text_size: %d (0x%0x)\n", text_size, text_size);
    fprintf(stdout, "text[] = {\n");
    for (int j = 0; j < text_size; j++)
    {
        fprintf(stdout, "  0x%02x", text[j]);
    }
    fprintf(stdout, "\n}\n");
}

static const char* options =
    "OPTIONS:\n"
    "=======\n"
    " -h            this help\n"
    " -x            show contents in ascii-hexa\n"
    " -d            debug mode\n";

int main(int argc, char* argv[])
{
    /* mode variables */
    bool show_only = false;
    bool debug = false;

    /* process command line arguments */
    int op = -1;
    while ((op = getopt(argc, argv, "hsd")) != -1)
    {
        switch (op)
        {
            case 'h':
                printf("%s [OPTIONS] lsm-file\n%s\n", argv[0], options);
                return 0;
            case 'd':
                debug=true;
                break;

            case 's':
                show_only = true;
                break;

            default:
                fprintf(stderr, "Bad option\n");
                printf("%s [OPTIONS] input-file\n%s\n", argv[0], options);
                return EXIT_FAILURE;
        }
    }

    /* check if mandatory argument is present */
    if (argc - optind != 1)
    {
        fprintf(stderr, "Mandatory argument is not present\n");
        return EXIT_FAILURE;
    }


    /* create virtual machine */
    LSMVM vm(argv[optind]);
    if (vm.bad())
    {
        fprintf(stderr, "LSMVM not good\n");
        return EXIT_FAILURE;
    }

    /* show or execute */
    if (show_only)
    {
        vm.show();
    }
    else
    {
        vm.debug = debug;
        vm.run();
    }

    /* that's all */
    return 0;
}

void LSMVM::alu(uint8_t opcode)
{
    uint32_t a = getNumber_DS();
    uint32_t b;
    uint32_t result;
     if(opcode!=0x15)
    {
        b = getNumber_DS();

        // iadd
        if(opcode==0x10)
        {
            result = b+a;
            if(debug)
                printf("\n%d+%d=%d",a,b,result);
        }

        // isub
        else if(opcode==0x11)
        {
            result = b-a;
            if(debug)
            printf("\n%d-%d=%d",b,a,result);
        }

        // imul
        else if(opcode==0x12)
        {
            result = b*a;
            if(debug)
                printf("\n%d*%d=%d",b,a,result);
        }

        // idiv
        else if(opcode==0x13)
        {
            result = b/a;
            if(debug)
                printf("\n%d/%d=%d",b,a,result);
        }

        // irem
        else if(opcode==0x14)
        {
            result = b%a;
            if(debug)
                printf("\n%dmod%d=%d",b,a,result);
        }

        // ineg
        else if(opcode==0x16)
        {
            result = b&a;
            if(debug)
                printf("\n%dand%d=%d",b,a,result);
        }

        // ior
        else if(opcode==0x17)
        {
            result = b|a;
            if(debug)
                printf("\n%dor%d=%d",b,a,result);
        }

        // ixor
        else if(opcode==0x18)
        {
            result = b^a;
            if(debug)
                printf("\n%dxor%d=%d",b,a,result);
        }

        // ishl
        else if(opcode==0x19)
        {
            result = b<<a;
            if(debug)
                printf("\n%d<<%d=%d",b,a,result);
        }

        // ishr
        else if(opcode==0x1a)
        {
            result = (signed int)(b)>>a;
            if(debug)
                printf("\n%d>>%d=%d",b,a,result);
        }

        // iushr
        else if(opcode==0x1b)
        {
            result = (unsigned int)(b>>a);
            if(debug)
                printf("\n%du>>%d=%d",b,a,result);
        }
    }

    else if(opcode==0x15)
    {
        result = -a;
        if(debug)
            printf("\n-%d=%d",a,result);
    }
    else
    {
        printf("\nA fatal error ocurred.");
        exit(1);
    }
    ds.push(result);

}

uint32_t LSMVM::getNumber_DS()
{
  if(ds.empty()){
  	printf("\nA fatal error ocurred.");
    exit(1);
  }
  uint32_t a = ds.top();
  ds.pop();
  return a;
}

void LSMVM::fpu(uint8_t opcode)
{
    word.ivalue = getNumber_DS();
	float a = word.fvalue;
	float b;

	if(opcode != 0x25 && opcode != 0x26 && opcode != 0x27 && opcode!=28)
	{
		word.ivalue = getNumber_DS();
        b = word.fvalue;

		// fadd
		if(opcode == 0x20)
		{
			word.fvalue = b + a;
            if(debug)
    			printf("\n%f+%f=%f",b,a,word.fvalue);
		}

		// fsub
		else if(opcode == 0x21)
		{
			word.fvalue = b - a;
            if(debug)
    			printf("\n%f-%f=%f",b,a,word.fvalue);
		}

		// fmul
		else if(opcode == 0x22)
		{
			word.fvalue = b * a;
            if(debug)
    			printf("\n%f*%f=%f",b,a,word.fvalue);
		}

		// fdiv
		else if(opcode == 0x23)
		{
			word.fvalue = b / a;
            if(debug)
    			printf("\n%f/%f=%f",b,a,word.fvalue);
		}

		// frem
		else if(opcode == 0x24)
		{
			word.fvalue = fmodf(b,a);
            if(debug)
    			printf("\n%f mod %f=%f",b,a,word.fvalue);
		}

		//fcmpg
		else if (opcode == 0x28)
		{
		  	word.fvalue = b - a;
		  	if(word.fvalue>0)
		    	word.ivalue = 1;
		  	else if(word.fvalue==0)
		    	word.ivalue = 0;
		    else
		      word.ivalue = -1;
		    if(debug)
		      printf("\n%f-%f=%d",b,a,word.ivalue);
		}
	}

	else if(opcode==0x25)
	{
		word.fvalue = -a;
        if(debug)
    		printf("\na = %f\n",word.fvalue);
	}
	// i2f
	else if(opcode == 0x26)
	{
		word.fvalue = (float)word.ivalue;
        if(debug)
            printf("\na (now float) = %f\n",word.fvalue);
	}

	// f2i
	else if (opcode == 0x27)
	{
		word.ivalue = (int)a;
        if(debug)
    		printf("\na (now int) = %d\n",word.ivalue);
	}

	else
	{
		printf("\nA fatal error ocurred");
		exit(1);
	}

	ds.push(word.ivalue);
}

void LSMVM::jump(uint8_t op)
{
    int16_t label;

    if(op>=0x30 && op<=0x37){
        step();
        uint8_t l1, l2;
        l1 = text[ip];
        step();
        l2 = text[ip];
        label = l1<<8|l2;
        if(debug)
        	printf("\nLABEL: %d",label);
    }

	if (op == 0x30)
	{
        ip = ip+label-3;
	}
	else if (op == 0x31)
	{
        cs.push(ip);
        ip = ip+label-3;
	}

	else if(op>=0x32 && op<=0x37)
	{
        int32_t a = getNumber_DS();
		if (op == 0x32)
		{
        	ip=(a==0)?ip-3+label:ip;
		}
		else if (op == 0x33)
		{
        	ip=(a!=0)?ip-3+label:ip;
		}
		else if (op == 0x34)
		{
        	ip=(a<0)?ip-3+label:ip;
        }
		else if (op == 0x35)
		{
        	ip=(a>=0)?ip-3+label:ip;
		}
		else if (op == 0x36)
		{
        	ip=(a>0)?ip-3+label:ip;
    	}
		else if (op == 0x37)
		{
        	ip=(a<=0)?ip-3+label:ip;
		}
	}
  	else if(op == 0x40)
  	{
  		if(cs.empty()){
  			printf("\nA fatal error ocurred.");
    		exit(1);
  		}
    	ip = cs.top();
    	cs.pop();
  	}
  	else{
    	printf("\nA fatal error ocurred.");
    	exit(1);
  	}
}

void LSMVM::dataStack(uint8_t op)
{
	int32_t a=0, b, i, v;
    uint8_t o1,o2,o3,o4;

	if (op == 0x50) // bipush
	{
        step();
        byte.ivalue = text[ip];
        ds.push(byte.ivalue);
        if(debug)
            printf("\nPUSH: %d",byte.ivalue);
	}
	else if (op == 0x51) // ipush
	{
		step();
        o1 = text[ip];
        step();
        o2 = text[ip];
        step();
        o3 = text[ip];
        step();
        o4 = text[ip];

        a = o1<<24|o2<<16|o3<<8|o4;
        ds.push(a);
        if(debug)
            printf("\nPUSH: %d",a);

	}
	else if (op == 0x52) //fpush
	{

        step();
        o1 = text[ip];
        step();
        o2 = text[ip];
        step();
        o3 = text[ip];
        step();
        o4 = text[ip];

        word.ivalue = o1<<24|o2<<16|o3<<8|o4;
        ds.push(word.ivalue);
        if(debug)
            printf("\nPUSH: %f",word.fvalue);

	}
	else if (op == 0x53) // pop
	{
		if(ds.empty()) goto data_error;
		ds.pop();
	}
	else if (op == 0x54) //dup
	{
		if(ds.empty()) goto data_error;
		a = ds.top();
		ds.push(a);
	}
	else if(op>=0x55 && op<=0x57){
		if(ds.size()<2) goto data_error;
		a = ds.top();
		ds.pop();
		b = ds.top();
		ds.pop();

		if (op == 0x55) // dup_x1
		{
			ds.push(a);
			ds.push(b);
			ds.push(a);
		}
		else if (op == 0x56) // dup2
		{
			ds.push(b);
			ds.push(a);
			ds.push(b);
			ds.push(a);
		}
		else if (op == 0x57) // swap
		{
			ds.push(a);
			ds.push(b);
		}
	}


	else if (op == 0x60) // load
	{
        int16_t label;
        step();
        uint8_t l1, l2;
        l1 = text[ip];
        step();
        l2 = text[ip];
        label = l1<<8|l2;

        if(label>data_size+bss_size) goto data_error;

		ds.push(data[label]);
        if(debug)
            printf("\nPUSH: %X",data[label]);
	}


	else if (op == 0x61) // store
	{
		int16_t label;
        step();
        uint8_t l1, l2;
        l1 = text[ip];
        step();
        l2 = text[ip];
        label = l1<<8|l2;


        if(ds.empty() || label>=data_size+bss_size) goto data_error;

        data[label]=ds.top();
        ds.pop();
        //printf("\nSAVED: %X",data[label]);
        if(debug)
            printf("\nSAVED: %X",data[label]);
	}

  	else if(op == 0x63 || op == 0x65 || op == 0x67)
   	{
    	if(ds.size()<3) goto data_error;

     	v = ds.top();
     	ds.pop();

     	i = ds.top();
	    ds.pop();

	    a = ds.top();
	    ds.pop();
        
        if(a+i>data_size+bss_size) goto data_error;
        //printf("\nStore in position %d of %d in place of %d",a+i,v,data[a+i]);
	    if(debug)
	    	printf("\nStore in position %d of %d in place of %d",a+i,v,data[a+i]);

	    data[a+i] = v;
  	}

  	else if(op == 0x62 || op == 0x64 || op == 0x66){
  		if(ds.size()<2) goto data_error;

     	i = ds.top();
	    ds.pop();

	    a = ds.top();
	    ds.pop();

        if(a+i>data_size+bss_size) goto data_error;

	    if(debug)
	    	printf("\nLoad of position %d: %d",a+i,data[a+i]);

	    ds.push(data[a+i]);
  	}

    else if(op == 0x68){
        if(ds.size()<1) goto data_error;

        a = ds.top();
        ds.pop();

        if(a>data_size) goto data_error;

        std::stack<uint32_t> strStack;

        strStack.push(data[a++]);

        while((data[a-1] & 0xFF)!=0 && a<data_size){
            strStack.push(data[a++]);
        }

        while(!strStack.empty()){
            ds.push(strStack.top());
            strStack.pop();
        }

        if(debug)
            printf("\nLoad of string");
    }

    else if(op == 0x69) //laload
    {
    	uint16_t label;
    	uint8_t l1, l2;
    	step();
        l1 = text[ip];
        step();
        l2 = text[ip];
        label = l1<<8|l2;

	    ds.push(label);

	    if(debug)
	    	printf("\nLoad label: %d",label);

    }


    else
    {
        goto data_error;
    }

    return;

    data_error:
    	printf("\nA fatal error ocurred.");
        exit(1);

}

void LSMVM::other_instructions(uint8_t op)
{
	if (op == 0xf0) //halt
	{
		printf("\nProgram exiting\n");
		exit(0);
	}

	else if (op == 0xf1) // read
	{

        char in;
        scanf("%c",&in);
        ds.push(in);

	}
	else if (op == 0xf2) // write
	{
		if(ds.empty()){
  			printf("\nA fatal error ocurred.");
    		exit(1);
  		}
		char c = ds.top();
		ds.pop();
		printf("%c",c);

	}
    else if(op == 0xf3){
        int i;
        if(ds.empty()){
            printf("\nA fatal error ocurred.");
            exit(1);
        }

        printf("\n > ");

        while(!ds.empty() && (ds.top() & 0xFF)!=0){
            for(i=3;i>=0;i--){
                printf("%c",(ds.top()>>i*8)&0xFF);
            }
            ds.pop();
        }

        if(!ds.empty()){
            for(i=3;i>=0;i--){
                printf("%c",(ds.top()>>i*8)&0xFF);
            }
            ds.top();
        }
    }

	else if (op == 0x00) // nop
	{
		if(debug)
			printf("\nNOP");
		return;
	}
	else
	{
		printf("\nA fatal error ocurred.\n");
		exit(1);
	}
}
