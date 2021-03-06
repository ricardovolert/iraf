# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<plset.h>
include	<plio.h>

# PL_R2L -- Convert a range list to a line list.  The length of the output
# line list is returned as the function value.

int procedure pl_r2ls (rl_src, xs, ll_dst, npix)

short	rl_src[3,ARB]		#I input range list
int	xs			#I starting pixel index in range list
short	ll_dst[ARB]		#O destination line list
int	npix			#I number of pixels to convert

short	hi, pv
int	last, xe, x1, x2, iz, op, np, nz, nr, dv, v, i
define	done_ 91

begin
	# No input pixels?
	nr = RL_LEN(rl_src)
	if (npix <= 0 || nr <= 0)
	    return (0)

	# Initialize the linelist header.
	LL_VERSION(ll_dst) = LL_CURVERSION
	LL_HDRLEN(ll_dst) = LL_CURHDRLEN
	LL_NREFS(ll_dst) = 0
	LL_SETBLEN(ll_dst,0)

	xe = xs + npix - 1
	op = LL_CURHDRLEN + 1
	iz = xs
	hi = 1

	# Process the array of range lists.
	do i = RL_FIRST, nr + 1 {
	    if (i <= nr) {
		# Load next range.
		x1 = rl_src[1,i]
		np = rl_src[2,i]
		pv = rl_src[3,i]
		x2 = x1 + np - 1
		last = x2

		# Get an inbounds range.
		if (x1 > xe)
		    break
		else if (xs > x2)
		    next
		else if (x1 < xs)
		    x1 = xs
		else if (x2 > xe)
		    x2 = xe

		# Go again if nothing inbounds.
		nz = x1 - iz
		np = x2 - x1 + 1
		if (np <= 0)
		    next

	    } else if (iz < xe) {
		# At end of input range list, but need to output a ZN.
		nz = xe - iz + 1
		np = 0
		pv = 0
	    } else
		break

	    # Encode an instruction to regenerate the current range I0-IP
	    # of N data values of nonzero level PV.  In the most complex case
	    # we must update the high value and output a range of zeros,
	    # followed by a range of NP high values.  If NP is 1, we can
	    # probably use a PN or [ID]S instruction to save space.

	    # Change the high value?
	    if (pv > 0) {
		dv = pv - hi
		if (dv != 0) {
		    # Output IH or DH instruction?
		    hi = pv
		    if (abs(dv) > I_DATAMAX) {
			ll_dst[op] = M_SH + and (int(pv), I_DATAMAX)
			op = op + 1
			ll_dst[op] = pv / I_SHIFT
			op = op + 1
		    } else {
			if (dv < 0)
			    ll_dst[op] = M_DH + (-dv)
			else
			    ll_dst[op] = M_IH + dv
			op = op + 1

			# Convert to IS or DS if range is a single pixel.
			if (np == 1 && nz == 0) {
			    v = ll_dst[op-1]
			    ll_dst[op-1] = or (v, M_MOVE)
			    goto done_
			}
		    }
		}
	    }

	    # Output range of zeros to catch up to current range?
	    if (nz > 0) {
		# Output the ZN instruction.
		for (;  nz > 0;  nz = nz - (I_DATAMAX-1)) {
		    ll_dst[op] = M_ZN + min(I_DATAMAX-1,nz)
		    op = op + 1
		}
		# Convert to PN if range is a single pixel.
		if (np == 1 && pv > 0 && x2 == last) {
		    ll_dst[op-1] = ll_dst[op-1] + M_PN + 1
		    goto done_
		}
	    }

	    # The only thing left is the HN instruction if we get here.
	    for (;  np > 0;  np = np - I_DATAMAX) {
		ll_dst[op] = M_HN + min(I_DATAMAX,np)
		op = op + 1
	    }
done_
	    iz = x2 + 1
	}

	LL_SETLEN(ll_dst, op - 1)
	return (op - 1)
end
