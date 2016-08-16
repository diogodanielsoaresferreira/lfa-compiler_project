CXX = g++
CXXFLAGS = -Wall -std=c++11

ANCLASSES += astNode

NCLASSES += astBreak
NCLASSES += astExit
NCLASSES += astFloatDecl
NCLASSES += astIf
NCLASSES += astArrayDecl
NCLASSES += astArrayInitialize
NCLASSES += astByteDecl
NCLASSES += astIntDecl
NCLASSES += astStringDecl
NCLASSES += astLoop
NCLASSES += astPrintStr
NCLASSES += astProgram
NCLASSES += astSeq
NCLASSES += astSpaceDecl

AVCLASSES += astValue

VCLASSES += astIntegerValue
VCLASSES += astNeg
VCLASSES += astFloatValue
VCLASSES += astStringValue
VCLASSES += astArrayValue
VCLASSES += astByteValue
VCLASSES += astVarValue
VCLASSES += astProcedureCall
VCLASSES += astEndProcedure
VCLASSES += astSeqValue
VCLASSES += astFunctionCall
VCLASSES += astPrint
VCLASSES += astAssignToVar
VCLASSES += astAssignToArray
VCLASSES += astCast
VCLASSES += astRelop
VCLASSES += astOperation

OBJS += $(ANCLASSES:%=%.o)
OBJS += $(NCLASSES:%=%.o)
OBJS += $(VCLASSES:%=%.o)

libast.a :	$(OBJS)
	ar cr $@ $^

$(NCLASSES:%=%.o):	%.o:	%.h $(ANCLASSES:%=%.h)
$(VCLASSES:%=%.o):	%.o:	%.h $(ANCLASSES:%=%.h) $(AVCLASSES:%=%.h)
$(ANCLASSES:%=%.o):	%.o:	%.h

clean:  
	rm -rf *.o

cleanall:	clean
	rm -f libast.a
