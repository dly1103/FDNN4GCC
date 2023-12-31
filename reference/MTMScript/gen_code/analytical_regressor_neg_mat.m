function Regressor_Matrix_Neg = analytical_regressor_neg_mat(g,q2,q3,q4,q5,q6)
%ANALYTICAL_REGRESSOR_NEG_MAT
%    REGRESSOR_MATRIX_NEG = ANALYTICAL_REGRESSOR_NEG_MAT(G,Q2,Q3,Q4,Q5,Q6)

%    This function was generated by the Symbolic Math Toolbox version 8.3.
%    17-Oct-2019 18:15:27

t2 = cos(q2);
t3 = cos(q3);
t4 = cos(q4);
t5 = cos(q5);
t6 = cos(q6);
t7 = sin(q2);
t8 = sin(q3);
t9 = sin(q4);
t10 = sin(q5);
t11 = sin(q6);
t12 = q2+q3;
t13 = sin(t12);
t14 = g.*t2.*t3;
t15 = g.*t2.*t8;
t16 = g.*t3.*t7;
t17 = g.*t7.*t8;
t18 = t4.*t14;
t19 = t9.*t14;
t20 = t5.*t15;
t21 = t5.*t16;
t22 = t4.*t17;
t23 = t10.*t15;
t24 = t10.*t16;
t25 = t9.*t17;
t26 = -t15;
t27 = -t16;
t28 = -t17;
t29 = t5.*t18;
t30 = t10.*t18;
t31 = t6.*t19;
t32 = t5.*t22;
t33 = t11.*t19;
t34 = t6.*t23;
t35 = t6.*t24;
t36 = t10.*t22;
t37 = t6.*t25;
t38 = t11.*t23;
t39 = t11.*t24;
t40 = -t19;
t41 = -t20;
t42 = -t21;
t43 = t11.*t25;
t44 = -t22;
t45 = -t23;
t46 = -t24;
t59 = t14+t28;
t60 = t26+t27;
t47 = t6.*t32;
t48 = t11.*t32;
t49 = -t30;
t50 = -t32;
t51 = -t37;
t52 = -t38;
t53 = -t39;
t54 = -t43;
t55 = t6.*t29;
t56 = t11.*t29;
t61 = t18+t44;
t62 = t25+t40;
t57 = -t48;
t58 = -t55;
t63 = t36+t41+t42+t49;
t64 = t29+t45+t46+t50;
t65 = t33+t34+t35+t47+t54+t58;
t66 = t31+t51+t52+t53+t56+t57;
Regressor_Matrix_Neg = reshape([0.0,g.*t7,0.0,0.0,0.0,0.0,0.0,0.0,g.*t2,0.0,0.0,0.0,0.0,0.0,0.0,t59,t59,0.0,0.0,0.0,0.0,0.0,t60,t60,0.0,0.0,0.0,0.0,0.0,t61,t61,-g.*t9.*t13,0.0,0.0,0.0,0.0,t62,t62,-g.*t4.*t13,0.0,0.0,0.0,0.0,t63,t63,g.*t9.*t10.*t13,-g.*(t2.*t3.*t10-t7.*t8.*t10+t2.*t4.*t5.*t8+t3.*t4.*t5.*t7),0.0,0.0,0.0,t64,t64,-g.*t5.*t9.*t13,-g.*(-t2.*t3.*t5+t5.*t7.*t8+t2.*t4.*t8.*t10+t3.*t4.*t7.*t10),0.0,0.0,0.0,t65,t65,g.*t13.*(t4.*t11+t5.*t6.*t9),g.*(-t2.*t3.*t5.*t6+t5.*t6.*t7.*t8+t2.*t4.*t6.*t8.*t10+t3.*t4.*t6.*t7.*t10),g.*(t2.*t6.*t8.*t9+t3.*t6.*t7.*t9+t2.*t3.*t10.*t11-t7.*t8.*t10.*t11+t2.*t4.*t5.*t8.*t11+t3.*t4.*t5.*t7.*t11),0.0,0.0,t66,t66,g.*t13.*(t4.*t6-t5.*t9.*t11),-g.*(-t2.*t3.*t5.*t11+t5.*t7.*t8.*t11+t2.*t4.*t8.*t10.*t11+t3.*t4.*t7.*t10.*t11),g.*(t2.*t3.*t6.*t10-t2.*t8.*t9.*t11-t3.*t7.*t9.*t11-t6.*t7.*t8.*t10+t2.*t4.*t5.*t6.*t8+t3.*t4.*t5.*t6.*t7),0.0],[7,10]);
