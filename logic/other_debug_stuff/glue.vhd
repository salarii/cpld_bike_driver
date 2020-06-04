library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package  glue is

	procedure   initFile (dummy : in  integer);
	attribute  foreign of initFile : 
	procedure is "VHPIDIRECT  initFile ";	

	procedure   initPlant (dummy : in  integer);
	attribute  foreign of initPlant : 
	procedure is "VHPIDIRECT  initPlant ";		
	
	procedure   logData (time: in  integer ;value : in  integer );
	attribute  foreign of logData : 
	procedure is "VHPIDIRECT  logData ";
	
	function   regToPlant (value : in  integer ) return integer;
	attribute  foreign of regToPlant : 
	function is "VHPIDIRECT  regToPlant ";

end;

package  body  glue is

procedure  logData (time: in  integer ;value : in  integer ) is
begin
	assert  false  report "VHPI" severity  failure;
end logData;

procedure  initFile (dummy : in  integer) is
begin
	assert  false  report "VHPI" severity  failure;
end initFile;

procedure  initPlant (dummy : in  integer) is
begin
	assert  false  report "VHPI" severity  failure;
end initPlant;

function  regToPlant (value : in  integer ) return integer  is
begin
	assert  false  report "VHPI" severity  failure;
end regToPlant;

end glue;