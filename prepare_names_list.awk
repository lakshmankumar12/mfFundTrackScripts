BEGIN {
  FS=";"
}
/Schemes/ {
  current_scheme=$0;
  gsub("[[:space:]]*$","",current_scheme);
  next;
}
/;/ {
  if ( current_scheme!="" ) {
    print $4 "; ;" current_scheme ";" current_company ";"
  }
  next
}
/[[:alpha:]]/ {
  current_company=$0;
  gsub("[[:space:]]*$","",current_company);
  next;
}
