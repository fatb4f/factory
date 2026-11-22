#!/usr/bin/env python3
"""Exact arithmetic only. Class selection, causation and legal applicability are inputs."""
from decimal import Decimal, localcontext, ROUND_DOWN, ROUND_HALF_UP, ROUND_CEILING
import json
import subprocess
from functools import lru_cache
from ivac_regulatory import ROOT


@lru_cache(maxsize=1)
def policy():
    return json.loads(subprocess.check_output(['cue','export','./contracts/personal/ivac:ivac',
                       '-e','regulatoryArithmeticPolicy','--out','json'],cwd=ROOT),parse_float=Decimal)


def percentage(value):
    if isinstance(value,(float,bool)):
        raise ValueError('use Decimal or a decimal string, never binary float or boolean')
    result=Decimal(value)
    if not result.is_finite() or not 0<=result<=100:
        raise ValueError('percentage outside [0,100]')
    return result


def difference(current, baseline):
    current=percentage(current)
    if baseline is None: return {'state':'unresolved','reason':policy()['unknownBaseline']}
    baseline=percentage(baseline)
    if current<baseline: return {'state':'unresolved','reason':policy()['negativeDifference']}
    return {'state':'computed','percentage':current-baseline}


def bilateral(left, right, *, eligible, cap_order):
    """left/right are totals for the two specified upper-limb units, not all limbs.

    Caller must establish bilateral eligibility and at least one related qualifying
    sequela. The original fraction is (L+R)/8; its XML table was inspected.
    """
    if eligible is not True: raise ValueError('explicit clinically/legal qualified eligibility required')
    if cap_order not in ('cap-then-round','round-then-cap'):
        raise ValueError('explicit cap/round interpretation required')
    left,right=percentage(left),percentage(right)
    if not left or not right: raise ValueError('both sides must have qualifying impairment')
    p=policy();cap=min(left,right)
    with localcontext() as ctx:
        ctx.prec=80
        raw=max(Decimal(str(p['bilateralMinimum'])),(left+right)/Decimal(p['bilateralDivisor']))
        def rounded(v):
            # Discard all but first decimal, then raise 1..4→5, 6..9→next integer.
            first=v.quantize(Decimal('0.1'),rounding=ROUND_DOWN)
            return (first*2).to_integral_value(rounding=ROUND_CEILING)/2
        result=rounded(min(raw,cap)) if cap_order=='cap-then-round' else min(rounded(raw),cap)
    return {'state':'computed-under-explicit-reading','percentage':result,'reading':cap_order,
            'raw':raw,'cap':cap,'adjudication':'not-determined'}


def aggregate(values):
    rates=sorted([percentage(v) for v in values],reverse=True)
    if not rates: raise ValueError('missing rates is unknown, not zero')
    p=policy();base=Decimal(p['percentageBase']);contributions=[]
    with localcontext() as ctx:
        ctx.prec=max(80,sum(len(x.as_tuple().digits) for x in rates)+20)
        total=rates[0];contributions.append(total)
        quantum=Decimal(1).scaleb(-p['residualContributionDecimalPlaces'])
        for rate in rates[1:]:
            contribution=((base-total)*rate/base).quantize(quantum,rounding=ROUND_HALF_UP)
            contributions.append(contribution);total+=contribution
        # The global ceiling clause is introduced for multiple percentages.
        result=total.to_integral_value(rounding=ROUND_CEILING) if len(rates)>1 else total
    return {'state':'computed','orderedRates':rates,'contributions':contributions,
            'beforeGlobalRounding':total,'percentage':result,'adjudication':'not-determined'}
