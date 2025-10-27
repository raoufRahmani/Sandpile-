ods path reset;
ods path (prepend) sashelp.tmplmst(read);
ods graphics on;

proc iml;
nbr_iterations = 100000;
nbr_lig =50;
nbr_col = 50;
Matrice = J(nbr_lig, nbr_col, 0);
Avalanches = J(nbr_iterations, 2, .);

do a = 1 to nbr_iterations;
	x = rand("integer", 1, nbr_lig);
	y = rand("integer", 1, nbr_col);
	Matrice[x, y] = Matrice[x, y] + 1;

N=0;
t=0;
do while(max(Matrice) >= 4);
 t = t + 1;/*Pour chaque itération, la boucle while se lance plusieurs fois, et ce nombre de fois est le t*/
indice = loc(Matrice >= 4);
do e = 1 to ncol(indice);
	i = floor((indice[e]-1)/nbr_col) + 1;
	j = mod(indice[e]-1, nbr_col) + 1;

	Matrice[i, j] = Matrice[i, j] - 4;
	if i < nbr_lig then Matrice[i+1, j] = Matrice[i+1, j] + 1;
	if j > 1 then Matrice[i, j-1] = Matrice[i, j-1] + 1;
	if j < nbr_col then Matrice[i, j+1] = Matrice[i, j+1] + 1;
	if i > 1 then Matrice[i-1, j] = Matrice[i-1, j] + 1;
end;
N = N + ncol(indice); /*N calcule pour chaque itération le nombre de cellules qui ont été =4 donc touchées */
end;

Avalanches[a,] = N || t;
end;
print matrice;
call heatmapcont(Matrice)
	colorramp = {"black" "gray" "dodgerblue" "red"}
	title = "Sandpile Model Visualization";

iteration = T(1:nbr_iterations);
outdata = iteration || Avalanches ;
create AvalanchesDS from outdata[colname={"iteration" ,"N","t"}];
append from outdata;
close AvalanchesDS;
quit;


/*avec t*/

proc sgplot data=AvalanchesDS;
  histogram t / scale=proportion;
  title "Distribution de la durée des avalanches (t)";
run;

proc freq data=AvalanchesDS noprint;
  tables t / nocum out=TableFreq_t;
run;


data TableFreq2_t;
  set TableFreq_t;
  division = Count / 50000;
run;





data TableFreq2_t_log;
  set TableFreq2_t;
  if t > 0 and division > 0; 
  logT = log(t); 
  logP = log(division); 
run;


proc sgplot data=TableFreq2_t_log;
scatter x=logT y=logP / markerattrs=(color=blue);
Xaxis label="log(t)";
Yaxis label="log(P(t))";
title "Power-Law Relationship Between P(t) and t";
run;

proc reg data = TableFreq2_t_log;
model logP=logT;
run;


quit;

ods graphics off;
/*A chaque itération, on crée un vecteur indice des cellules >4,et on stocke la longueur du vecteur, et donc 
le nombre de cellules touvhées Dans N
A chaque itération, la boucle while va se lancer plusieurs fois sur les N cellules et sur les cellules qui suiveront
les cellules qui suiveront vont pas etre comptées dans les N*/
/*on utilise N et t pour la fonction de puissance, et on les représente en log -log*/

/*division c'est la probabiité de chaque de chaque durée d'avalanche*/

/*Il reste a grouper par effectif en log et le t(fréquence) en log aussi, le t en axe y*/

/*division = P(t)*/
/*Nombre de topplings observé*/
