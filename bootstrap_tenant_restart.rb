#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'common.rb')
require 'open3'

unless $pool.to_s.strip.length == 0

    ARGV.each do |a|
    if a.start_with?('-dataCenterCode=')
            $datacentercode=a.sub('-dataCenterCode=', '')
    end
    if a.start_with?('-zone=')
            $zone=a.sub('-zone=', '')
    end
    if a.start_with?('-tenant_id=')
            $customer=a.sub('-tenant_id=', '')
    end
    if a.start_with?('-pool=')
            $pool_id=a.sub('-pool=', '')
    end
    end


    tmsDBHost = Open3.popen3("grep #{$pool_id} ../../Automation-Config/#{$datacentercode}-#{$zone}/pool.properties | grep .tms.dbHost | cut -d '=' -f2"){ |stdin, stdout, stderr, wait_thr| stdout.read }.chomp
    tmsDBPort = Open3.popen3("grep #{$pool_id} ../../Automation-Config/#{$datacentercode}-#{$zone}/pool.properties | grep .tms.dbPort | cut -d '=' -f2"){ |stdin, stdout, stderr, wait_thr| stdout.read }.chomp
    tmsDBName = Open3.popen3("grep #{$pool_id} ../../Automation-Config/#{$datacentercode}-#{$zone}/pool.properties | grep .tms.dbServiceName | cut -d '=' -f2"){ |stdin, stdout, stderr, wait_thr| stdout.read }.chomp

    tmsDBPasswordEnc = Open3.popen3("grep #{$pool_id} ../../Automation-Config/#{$datacentercode}-#{$zone}/pool.properties | grep .tms.dbPassword | cut -d '=' -f2"){ |stdin, stdout, stderr, wait_thr| stdout.read }.chomp
    tmsDBUser = Open3.popen3("grep #{$pool_id} ../../Automation-Config/#{$datacentercode}-#{$zone}/pool.properties | grep .tms.dbUser | cut -d '=' -f2"){ |stdin, stdout, stderr, wait_thr| stdout.read }.chomp.upcase
    tmsDBPassword = getPassword($pool,tmsDBPasswordEnc)
    connectString = "#{tmsDBUser}/#{tmsDBPassword}@#{tmsDBHost}:#{tmsDBPort}/#{tmsDBName}"
    #bootStrapCheckQuery = "select user as Boot_Strap_Schema, decode( count(column_name), 1, \'Upgraded to b1605\', \'Not Upgraded to b1605\') as Status from user_tab_columns where table_name = \'PS_TENANT\' and column_name = \'CUSTOMER_FINANCE_ID\'\;"
    #bootStrapCheckQuery = "select USER as Boot_Strap_Schema,DATA_FLD_1 as Boot_Strap_Version from PS_BOOTSTRAP_METADATA where METADATA_ID='APP_VERSION' AND DATA_FLD_1 like '#{tmsAppVersion1}%' ;"
     bootStrapupdatenQuery = "update PS_TENANT set ACTIVE = 'N' where TENANT_ID = '#{$customer}';"
	 bootStrapupdateyQuery = "update PS_TENANT set ACTIVE = 'Y' where TENANT_ID = '#{$customer}';"
	 bootStrapcommitQuery = "commit;"
     bootStrapselectQuery = "select ACTIVE from PS_TENANT where TENANT_ID = '#{$customer}';"
    puts "#{bootStrapupdatenQuery}"
    puts "-----------------" + Time.new.strftime("%Y-%b-%d %H:%M:%S") + " START --Processing tenant #{$customer}-------------"
    puts "\nUpdating  ps_tenant table"
    puts "\n\nConnection String: #{connectString}\n\n"
    result = `echo \"set LINESIZE 30;\ncolumn Boot_Strap_Schema format a30;\n#{bootStrapupdatenQuery}\" | #{ORACLE_HOME}/bin/sqlplus #{connectString} 2>&1`.chomp
	result1 = `echo \"set LINESIZE 30;\ncolumn Boot_Strap_Schema format a30;\n#{bootStrapcommitQuery}\" | #{ORACLE_HOME}/bin/sqlplus #{connectString} 2>&1`.chomp
	result2 = `echo \"set LINESIZE 30;\ncolumn Boot_Strap_Schema format a30;\n#{bootStrapselectQuery}\" | #{ORACLE_HOME}/bin/sqlplus #{connectString} 2>&1`.chomp
	puts "#{result}"
	puts "#{result1}"
	puts "#{result2}"
	puts  "exit"
	
	puts "-------------------Sleping for 60 sec----------------"
	
	sleep 60
	puts "------" + Time.new.strftime("%Y-%b-%d %H:%M:%S") + " START --Processing tenant #{$customer}----------------"
	
	puts "\nUpdating  ps_tenant table"
	puts "\n\nConnection String: #{connectString}\n\n"
	result3 = `echo \"set LINESIZE 30;\ncolumn Boot_Strap_Schema format a30;\n#{bootStrapupdateyQuery}\" | #{ORACLE_HOME}/bin/sqlplus #{connectString} 2>&1`.chomp
	result4 = `echo \"set LINESIZE 30;\ncolumn Boot_Strap_Schema format a30;\n#{bootStrapcommitQuery}\" | #{ORACLE_HOME}/bin/sqlplus #{connectString} 2>&1`.chomp
	puts "#{result3}"
	puts "#{result4}"
	
	result5 = `echo \"set LINESIZE 30;\ncolumn Boot_Strap_Schema format a30;\n#{bootStrapselectQuery}\" | #{ORACLE_HOME}/bin/sqlplus #{connectString} 2>&1`.chomp
    puts "#{result5}"
	
    
end

