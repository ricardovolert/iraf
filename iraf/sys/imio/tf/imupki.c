/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#define import_spp
#define import_knames
#define import_xnames
#include <iraf.h>

/*
  IMUPK? -- Convert an array of pixels of datatype DTYPE into the datatype
  specified by the IMUPK? suffix character.
*/

static XINT Error_code = 1;
static XCHAR Error_msg[] = {'U','n','k','n','o','w','n',' ',
			    'd','a','t','a','t','y','p','e',' ','i','n',' ',
			    'i','m','a','g','e','f','i','l','e',XEOS };

int IMUPKI ( void *a, XINT *b, XSIZE_T *npix, XINT *dtype )
{
	switch ( *dtype ) {
	case TY_USHORT:
	    ACHTUI ((XUSHORT *)a, b, npix);
	    break;
	case TY_SHORT:
	    ACHTSI ((XSHORT *)a, b, npix);
	    break;
	case TY_INT:
	    ACHTII ((XINT *)a, b, npix);
	    break;
	case TY_LONG:
	    ACHTLI ((XLONG *)a, b, npix);
	    break;
	case TY_REAL:
	    ACHTRI ((XREAL *)a, b, npix);
	    break;
	case TY_DOUBLE:
	    ACHTDI ((XDOUBLE *)a, b, npix);
	    break;
	case TY_COMPLEX:
	    ACHTXI ((XCOMPLEX *)a, b, npix);
	    break;
	default:
	    ERROR (&Error_code, Error_msg);
	    break;
	}

	return 0;
}