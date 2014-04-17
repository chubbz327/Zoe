 $sql->{HASMANY}->{TestObject2} = [{TestObject2_LIST => 'TestObject1_ID'} ];
use Data::Dumper;

print Dumper $sql;
