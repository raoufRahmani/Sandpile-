ods path reset;
ods path (prepend) sashelp.tmplmst(read);
ods graphics on;

proc iml;
nbr_iterations = 90000;
nbr_lig = 245;
nbr_col = 245;
Matrice = J(nbr_lig, nbr_col, 0);

do a = 1 to nbr_iterations;
x = floor(nbr_lig/2);
y = floor(nbr_col/2);
Matrice[x, y] = Matrice[x, y] + 1;
do while(max(matrice)>=4);
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
end;
end;
call heatmapcont(Matrice)
    colorramp = {"black" "darkred" "orange" "yellow"};
    title = "Abelian sandpile model";
print Matrice;
quit;

ods graphics off;
