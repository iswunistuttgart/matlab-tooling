t1 = cos(vRotation(3));
t2 = cos(vRotation(2));
t3 = sin(vRotation(3));
t4 = cos(vRotation(1));
t5 = sin(vRotation(2));
t6 = sin(vRotation(1));
for iCable = 1:nNumberOfCables
	t7 = t1*t6;
	t8 = t3*t4;
	t9 = -t7*t5+t8;
	t10 = t1*t4;
	t11 = t3*t6;
	t12 = t10*t5+t11;
	t13 = t9*aCableAttachments(2,iCable);
	t14 = t12*aCableAttachments(3,iCable);
	t15 = t2*aCableAttachments(1,iCable);
	t16 = t15*t1;
	t17 = -t16-t14+t13+aPulleyPositions(1,iCable)-vPosition(1);
	t10 = t11*t5+t10;
	t7 = -t8*t5+t7;
	t8 = t15*t3;
	t11 = t10*aCableAttachments(2,iCable)-t7*aCableAttachments(3,iCable)+t8-aPulleyPositions(2,iCable)+vPosition(2);
	t18 = aCableAttachments(2,iCable)*t6;
	t19 = aCableAttachments(3,iCable)*t4;
	t20 = t19+t18;
	t21 = t5*aCableAttachments(1,iCable);
	t22 = -t2*t20+t21+aPulleyPositions(3,iCable)-vPosition(3);
	t18 = -t2*(t19+t18)+t21;
	t19 = 0.2e1;
	aJacobian(iCable,:) = [-t19*t17; ...
							t19*t11; ...
							-t19*t22; ...
							-t19*(t17*(t12*aCableAttachments(2,iCable)+t9*aCableAttachments(3,iCable))+t22*t2*(t4*aCableAttachments(2,iCable)-t6*aCableAttachments(3,iCable))+t11*(t10*aCableAttachments(3,iCable)+t7*aCableAttachments(2,iCable))); ...
							-t19*(-t17*t1*t18+t11*t3*t18-t22*(t20*t5+t15)); ...
							-t19*(t11*(-t16-t14+t13)-t17*(t10*aCableAttachments(2,iCable)-t7*aCableAttachments(3,iCable)+t8))];
end