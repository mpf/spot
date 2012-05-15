% Running fogtest with original Fog
Atic=0.002083 bytes=2376 btic=0.002616
Atic=0.000252 bytes=5448 btic=0.000185
Atic=0.000316 bytes=11592 btic=0.000228
Atic=0.000462 bytes=23880 btic=0.000261
Atic=0.000736 bytes=48456 btic=0.000306
Atic=0.001295 bytes=97608 btic=0.000343
Atic=0.002529 bytes=195912 btic=0.000385
Atic=0.005252 bytes=392520 btic=0.000419
Atic=0.016111 bytes=785736 btic=0.000571
Atic=0.032379 bytes=1572168 btic=0.000551
Atic=0.105233 bytes=3145032 btic=0.000665
Atic=0.390665 bytes=6290760 btic=0.000781
Atic=2.200265 bytes=12582216 btic=0.000840
Atic=32.876785 bytes=25165128 btic=0.000898
% Time and memory increase exponentially

% Running fogtest with Fog2 (children commented in Fog. boys only)
Atic=0.001911 bytes=872 btic=0.002730
Atic=0.000227 bytes=1272 btic=0.000180
Atic=0.000195 bytes=1672 btic=0.000219
Atic=0.000206 bytes=2072 btic=0.000263
Atic=0.000211 bytes=2472 btic=0.000297
Atic=0.000221 bytes=2872 btic=0.000336
Atic=0.000231 bytes=3272 btic=0.000378
Atic=0.000239 bytes=3672 btic=0.000417
Atic=0.000253 bytes=4072 btic=0.000454
Atic=0.000259 bytes=4472 btic=0.000493
Atic=0.000269 bytes=4872 btic=0.000534
Atic=0.000278 bytes=5272 btic=0.000573
Atic=0.000286 bytes=5672 btic=0.000613
Atic=0.000294 bytes=6072 btic=0.000652
% Time and memory does not increase exponentially

% Fog3 (boys replaced with children, both not commented)
Atic=0.003119 bytes=2376 btic=0.003877
Atic=0.000438 bytes=5448 btic=0.000250
Atic=0.000445 bytes=11592 btic=0.000328
Atic=0.000629 bytes=23880 btic=0.000376
Atic=0.001061 bytes=48456 btic=0.000492
Atic=0.001863 bytes=97608 btic=0.000669
Atic=0.003558 bytes=195912 btic=0.000566
Atic=0.008011 bytes=392520 btic=0.000688
Atic=0.018717 bytes=785736 btic=0.000699
Atic=0.045915 bytes=1572168 btic=0.000916
Atic=0.131175 bytes=3145032 btic=0.000704
Atic=0.399702 bytes=6290760 btic=0.000795
Atic=2.603501 bytes=12582216 btic=0.000860
Atic=34.148164 bytes=25165128 btic=0.000899
% Time and memory increases exponentially

% Fog4 (children removed from Mist entirely, boys only)
Atic=0.002556 bytes=872 btic=0.003577
Atic=0.000261 bytes=1272 btic=0.000248
Atic=0.000260 bytes=1672 btic=0.000300
Atic=0.000266 bytes=2072 btic=0.000374
Atic=0.000288 bytes=2472 btic=0.000423
Atic=0.000288 bytes=2872 btic=0.000506
Atic=0.000338 bytes=3272 btic=0.000545
Atic=0.000323 bytes=3672 btic=0.000574
Atic=0.000321 bytes=4072 btic=0.000624
Atic=0.000330 bytes=4472 btic=0.000675
Atic=0.000342 bytes=4872 btic=0.000732
Atic=0.000359 bytes=5272 btic=0.000781
Atic=0.000366 bytes=5672 btic=0.000832
Atic=0.000370 bytes=6072 btic=0.000882
% Time and memory does not increase exponentially

% Fog5 same as Fog except A & B doubled at construction time
Atic=0.004732 bytes=840 btic=0.000838
Atic=0.000502 bytes=840 btic=0.000122
Atic=0.000331 bytes=840 btic=0.000379
Atic=0.000337 bytes=840 btic=0.000108
Atic=0.000312 bytes=840 btic=0.000107
Atic=0.000310 bytes=840 btic=0.000108
Atic=0.000314 bytes=840 btic=0.000107
Atic=0.000321 bytes=840 btic=0.000110
Atic=0.000325 bytes=840 btic=0.000107
Atic=0.000314 bytes=840 btic=0.000107
Atic=0.000314 bytes=840 btic=0.000108
Atic=0.000313 bytes=840 btic=0.000106
Atic=0.000310 bytes=840 btic=0.000107
Atic=0.000309 bytes=840 btic=0.000107
% Time and memory does not increase exponentially

% Thus, it can be concluded that the duplication of the operators at
% construction time has minor effect compared to the non-doubling of the
% operators at multiplication time