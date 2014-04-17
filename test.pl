$v = "admin,admin,user";

$u = "user";


print 1 if ($v =~/$u/);
print 2 if ($u =~/$v/);
