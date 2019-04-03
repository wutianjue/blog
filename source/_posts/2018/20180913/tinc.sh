#!/bin/bash
net_name=""
node_name=""
is_client=""
mk_dir(){
    while [ -z ${net_name} ]
    do
        read -p "Enter the network name:" net_name
        net_name=$net_name|sed 's/ //g'
    done
    mkdir $net_name
    cd $net_name
    mkdir 'hosts'
}
tinc_conf(){
    read -p "Enter Interface Name:" interface
    read -p "Enter local node name:" node_name
    conf_str="Interface = ${interface} \nName = ${node_name}"
    read -p "Is client node?(y/n):" is_client
    if [ "$is_client" == "y" ]
    then
        read -p "Enter server node name:" server_name
	conf_str=$conf_str"\nConnectTo = ${server_name}"
    fi
    echo -e $conf_str > 'tinc.conf'
}
net_conf(){
    if [ "$is_client" == "y" ]
    then
        read -p "Enter public IP address(can be empty):" pub_ip
    else
	while [ -z ${pub_ip} ]
	do
          read -p "Enter public IP address:" pub_ip
	  pub_ip=$pub_ip|sed 's/ //g'
        done
    fi
    read -p "Enter local node ip:" local_ip
    net_str="Subnet = ${local_ip}/24"
    pub_ip=$pub_ip|sed 's/ //g'
    if [ -n "$pub_ip" ]
    then
       net_str=$net_str"\nAddress = $pub_ip"
    fi
    cd hosts
    echo -e $net_str > $node_name
    cd ..
    os=`uname`
    if [ `uname` = "Linux" ]
    then
        echo -e "#!/bin/bash\n"'ifconfig $INTERFACE '"${local_ip} netmask 255.255.255.0" > 'tinc-up'
        echo -e "#!/bin/bash\n"'ifconfig $INTERFACE down' > 'tinc-down'
	chmod +x tinc-*
	tincd -n $net_name -K
    else
        ./tincd -n $net_name -K
    fi
}
mk_dir
tinc_conf
net_conf
