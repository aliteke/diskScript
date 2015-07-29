#!/usr/bin/perl

use strict;
use warnings;

my $app = Deneme::ExampleApp->new;
$app->MainLoop;

##################################

package Deneme::ExampleApp;
use strict;
use warnings;

use base 'Wx::App';

sub OnInit{
    my $frame = Deneme::ExampleApp::BoxSizerExampleFrame->new;
    $frame->Show(1);
}

##################################

package Deneme::ExampleApp::BoxSizerExampleFrame;

use Wx qw (:everything);
use Wx::Event qw(EVT_BUTTON);

# include for Secure Copy Protocol
use Net::SCP qw(scp iscp);

use base 'Wx::Frame';

my $txtCtrlDD;
my $statTxtSCP;
my $txtCtrlSCP;
my $lbl3;


my @params;  
my @defaultValues;

my %USBdevs;        # This Hash holds the USB Disk info like this; 
            # %USBdevs = ('/dev/sdc', '/media/XYZXYZX');

my %hashDefaults;

# remote server login credentials

my $username;
my $hostname;
my $remoteDir;

# my $password = "XXXXXX";    
# not needed, using RSA pub/private key pair. Put id_rsa.pub into .ssh/authorized_keys file in the remote host. 
# for Passwordless Login


sub new {
        my $class = shift;
        my $self = $class->SUPER::new(    
        undef,                # parent
                    -1,                # let system decide the ID
                    'SpaceX InfoSec Disk Image Transfer Tool',        # title
                    [-1,-1],            # default position
                    [1300, 300],        # size (width, height)
    );

    @params = ("if", "of", "hash", "md5log", "sha256log", "hashconv", "bs", "verifylog", "status");
    @defaultValues = ("/dev/sdX", "Disk.img", "md5,sha256", "md5.log", "sha256.log", "after", "512", "verify.log", "on");

    %hashDefaults = ("if" => "/dev/sdX",
             "of" => "Disk.img",
             "hash" => "md5,sha256",
             "md5log"=> "md5.log",
             "sha256log"=> "sha256.log",
             "hashconv"=> "after",
             "bs"=> "512",
             "verifylog"=>"verify.log",
             "status"=> "on",
    );

    $hashDefaults{"username"} = "aliteke";
    $hashDefaults{"hostname"} = "10.32.109.76";
    $hashDefaults{"remoteDir"} = "/home/aliteke/TransferFiles";    

    my $vbox = Wx::BoxSizer->new( wxVERTICAL );    # BoxSizer is the layout manager

    my $pnl1 = Wx::Panel->new($self, -1);    # first panel
    my $pnl2 = Wx::Panel->new($self, -1);    # panels' parent is the Frame (self)
#    my $pnl3 = Wx::Panel->new($self, -1);
    my $pnl4 = Wx::Panel->new($self, -1);
    

#    $statTxtSCP = Wx::StaticText->new(
#        $pnl1,            # parent
#        -1,        # id,
#    "-Click scp button to Get the command we will use to Transfer the image to Remote Server-",   # label
#        wxDefaultPosition,    #[5,10],     # position
#    );

    $txtCtrlSCP = Wx::TextCtrl->new(
        $pnl1,                # parent
           -1,                # id,
    "-Click scp button to Get the command we will use to Transfer the image to Remote Server-",   # label
        wxDefaultPosition,           # position
        [1000, 30],            #size
        wxTE_LEFT|wxTE_READONLY|wxTE_MULTILINE
    );


    $txtCtrlDD = Wx::TextCtrl->new(
        $pnl2,                # parent
           -1,                # id,
     "-Click dd button below to see the command we will use to image disk in the Docking Station-",        # label
        wxDefaultPosition,           # position
        [1000, 30],            #size
        wxTE_LEFT|wxTE_READONLY|wxTE_MULTILINE
    );



    my $pnl1HBoxSizer = Wx::BoxSizer->new( wxHORIZONTAL );
#-> new ( $parent, $id, $label, $pos,  $size, $style, $validator, $name );
    my $btnButton1 = Wx::Button->new( $pnl1, -1, '---scp---', [-1,-1], [-1,-1], wxBU_EXACTFIT|wxBU_RIGHT );
    EVT_BUTTON( $self, $btnButton1, \&btnButton1Clicked );

    $pnl1HBoxSizer->Add( $txtCtrlDD, 1, wxEXPAND|wxALL, 3 );
    $pnl1HBoxSizer->Add( $btnButton1, 0, wxEXPAND|wxALL, 3 );
    $pnl1->SetSizer( $pnl1HBoxSizer );

    my $pnl2HBoxSizer = Wx::BoxSizer->new( wxHORIZONTAL );
    my $btnButton2 = Wx::Button->new( $pnl2, -1, '---dd---', [-1,-1], [-1,-1], wxBU_EXACTFIT|wxBU_RIGHT );
    EVT_BUTTON( $self, $btnButton2, \&btnButton2Clicked );

    $pnl2HBoxSizer->Add( $txtCtrlSCP, 1, wxEXPAND|wxALL, 3 );
    $pnl2HBoxSizer->Add( $btnButton2, 0, wxEXPAND|wxALL, 3 );
    $pnl2->SetSizer( $pnl2HBoxSizer );

#    my $lbl3 = Wx::StaticText->new(    
#        $pnl3,        # parent
#        -1,            # id,
#        "Testing: 3",    # label
#        [5,10],        # position
#    );

    # now we want to create a vbox for the 4th panel
    # in this we will put button and other panels
    
    my $pnl4Vbox = Wx::BoxSizer->new( wxVERTICAL );
    
    
    # we'll create a button panel and place the buttons 
    # horizontally
    my $btnBox = Wx::BoxSizer->new( wxHORIZONTAL );

    my $pnlBtns = Wx::Panel->new(
        $pnl4,        # parent
        -1,             # id
        [-1,-1],         # position    
        [-1,-1],         # size
        0         # border style
    );

#    my $pnl4Text = Wx::Panel->new(
#        $pnl4,        # parent
#        -1,        # id
#        [-1,-1],        # position
#        [-1,-1],         # size
#        0,         # wxSIMPLE_BORDER # border style
#    );


    my $btnRun = Wx::Button->new( $pnlBtns, -1, '--Run--');
    EVT_BUTTON( $self, $btnRun, \&btnRunClicked);

    my $btnCancel = Wx::Button->new( $pnlBtns, -1, '--Cancel--');
    EVT_BUTTON( $self, $btnCancel, \&btnCancelClicked);
        
#    $btnBox->Add( $btnButton1, 1, wxALIGN_BOTTOM, 0 );
#    $btnBox->Add( $btnButton2, 1, wxALIGN_BOTTOM, 0 );
    
    $btnBox->Add( $btnRun, 1, wxALIGN_BOTTOM,0 );
    $btnBox->Add( $btnCancel, 1, wxALIGN_BOTTOM, 0 );

    $pnlBtns->SetSizer($btnBox);

#    $pnl4Vbox->Add( $pnl4Text,
#        1,
#        wxEXPAND,
#            0
#    );
    
    $pnl4Vbox->Add( $pnlBtns,                 # widget
        1,                        # vertically stretchable    
        wxALIGN_BOTTOM | wxALIGN_RIGHT,        # alignment
        0                        # border pixels
    );

    $pnl4->SetSizer($pnl4Vbox);

    $vbox->Add( $pnl1, 1, wxEXPAND | wxALL, 3);
    $vbox->Add( $pnl2, 1, wxEXPAND | wxALL, 3);
#    $vbox->Add( $pnl3, 1, wxEXPAND | wxALL, 3);
    $vbox->Add( $pnl4, 1, wxEXPAND | wxALL, 3);

    $self->SetSizer( $vbox );

    return $self;
}


sub btnRunClicked {
        my( $self, $event ) = @_;
    print "Run Clicked..."."\n";

    my $answer = Wx::MessageBox( "Running DD command first", "Confirm", wxYES_NO|wxCENTRE|wxICON_INFORMATION );
    print "\n".$answer."\n";

    # Get the customized DD command from the text field named, txtCtrlDD
    # check if it's the first text or not
    if($answer == 2){
        print "Answer is Yes\n";
        my @ddTextFields = split( /\n/, $txtCtrlDD->GetValue() );
        my @scpTextFields = split( /\n/, $txtCtrlSCP->GetValue() );

        #
        # Array of ddTextFields should be traversed in a for loop and for each
        # USB devices DD command we should check the validity of the command...
        #
        for(my $k=0; $k<@ddTextFields ;$k++){
            my $ddTextField = $ddTextFields[$k];
            my $scpTextField = $scpTextFields[$k];

                
            if( !( $ddTextField =~ /^dcfldd/ && $ddTextField =~ /if=.+ / && $ddTextField =~ /of=.+/ && $ddTextField =~ /bs=\d+/) ){
                Wx::MessageBox( "Please, First click --dd-- button to get the default customized dcfldd command", "Click --dd-- first", wxOK|wxCENTRE|wxICON_INFORMATION, );
                print "Please click --dd-- button to get the default customized dcfldd command\n";

            }else{
                my $userName='';
                my @ddCmdSplitted = split( /\s+/, $ddTextField);
                my $results = "";

                for(my $p=0; $p<@ddCmdSplitted; $p++){
                    my $curField = $ddCmdSplitted[$p];
                    
                    #
                    # dcfldd if=/dev/sdc of=scarrick.img
                    #
                    if( $curField =~ /if=\/dev\/sd[a-z]+/ ){

                        print "Matched curField to /dev/sdx: -$curField-\n";
                        $curField = substr($curField, 3);        # return /dev/sdX
                        $userName = getUserName($curField);        # getUserName( $curfield );
                        print "got UserName too: -$userName-, breaking out of for loop\n";
                        last;                         # break the for loop...
                    }
                }
                if($userName eq '')
                    print "\n****ERROR**** Can Not find a matching /dev/sdx, thus could not get USERNAME !!!!!\n";
                

                #
                # right before running the DD command, mkdir a new dir on the current directory with the username, and cd to that dir
                # and issue the DD command in that directory so that hash and log files are located under the correct folder, which is the name of the user or the UUID of disk
                #
                
                if( not -d $userName ){        # directory does not exists !!!
                    $results = `mkdir $userName`;
                    print "\nResult of mkdir $userName: -$results-";

                }

                #
                # chdir to the $userName directory
                #
                my $result = chdir $userName;
                if( $result == 1 ){
                    print "Changed directory to $userName. Current directory is ";
                    print `pwd`;
                }else{
                    print "ERROR!!!, CAN NOT CHANGE DIRECTORY";
                    return;
                }

                #
                # now that we are in the new directory, execute DD command
                # dcfldd if=/dev/sdc of=ata-ST1000NM0031_Z1N20QCA.img hash=md5,sha256 md5log=md5.log sha256log=sha256.log hashconv=after bs=512 verifylog=verify.log status=on
                #
                
                print "\nrunning ". ( $k+1 ). "th DD command\n\t-$ddTextField-\n";
                # $results =`$ddTextField`;
                print "Results from DD Command: ".$results."\n";

                #
                # Should create a folder if they don't exist
                #
                print "\n running ".( $k+1 ). "th SCP command:\n\t-$scpTextField-\n";
                # $results =`$scpTextField`;
                print "Results from SCP Command: ".$results."\n";


            }
        }
    }
    elsif($answer == 8){
        print "No\n";
    }
}

sub btnCancelClicked {
        my( $self, $event ) = @_;
    print "Cancel Button..."."\n";
    
    print "Self: ".$self."\n";    
    $self->Close();
}

#
#    SCP command Update Button Clicked
#
sub btnButton1Clicked {
        my( $self, $event ) = @_;
        print "Button 1\n";
    print "calling sub getSCPcommand...\n";
    #Deneme::ExampleApp::BoxSizerExampleFrame->callDF;
    print $self."\n"; 
    print $event."\n";

    my $result = getSCPcommand();
    print "Result from Calling getSCPcommand: ".$result."\n";

#    $statTxtSCP->SetLabel($result);
    if( $result ne ''){
        $txtCtrlSCP->SetValue($result);
        $txtCtrlSCP->SetEditable("true");
    } else{
        print "\nCOULDN'T GET THE SCP COMMAND!!!\n";
        Wx::MessageBox( "COULDN'T GET SCP COMMAND", "NO SCP COMMAND!!!", wxOK|wxCENTRE|wxICON_INFORMATION, );
    }
}

#
#    DD Command Update Button Clicked
#
sub btnButton2Clicked {
    my( $self, $event ) = @_;
    print "\nButton 2 clicked, calling getDDCommand...\n";
    my $result = Deneme::ExampleApp::BoxSizerExampleFrame->getDDCommand;

    print "\nResult from getDDCommand: -".$result."-\n";

    if ($result ne ''){
        $txtCtrlDD->SetValue($result);
        $txtCtrlDD->SetEditable("true");    
    } else{
        print "\nCOULDN'T GET THE DD COMMAND!!!\n";
        Wx::MessageBox( "COULDN'T GET DD COMMAND", "NO DD COMMAND!!!", wxOK|wxCENTRE|wxICON_INFORMATION, );
    }
}

#
# Returns the default command to use for imaging the Disk Connected through USB HUB
#
sub getDDCommand {
    my $ddCmd = "dcfldd"; 
    my $command="";
    my $resultingCommand="";

    my @connDevs = Deneme::ExampleApp::BoxSizerExampleFrame->getConnectedUSBdevs;

    print "\nin getDDCommand, result from getConnectedUSBdevs(), result from sub: -@connDevs-\n";

    # current index of the SDX in @CONDEVS
    my $j=1;
    # for each USB device, 
    foreach( @connDevs ){
        my $connDev = $_;

        print "\nConnected Device #$j at: ".$connDev."\n";

        # search for first occurance of 'sd' in $connDev, which is supposed to be something like sdx
        # if index method returns something other than -1, then we have a USB device in the current Array Index
        # assign the sdx to defaultValues[0]
        if ( index($connDev, 'sd') != -1 ){
            $defaultValues[0]= "/dev/".$connDev;
            print "\nUSB at:***".$defaultValues[0]."***\n";

        }else{
            print "\nNo USB drives are connected!!!\n";
            Wx::MessageBox( "No USB Device is connected, please check that you have a USB Docking Station Plugged-in and try again...", "No USB attached", wxOK|wxCENTRE|wxICON_INFORMATION, );
            return '';
        }
    
        my $command = $ddCmd. "";
        
        for ( my $i=0; $i < @params; $i++ ){

            my $curDev = "/dev/".$connDev;
            # get the PrimaryUsername of the disk from the command
            my $userName = getUserName( $curDev );    
            print "\n---\nGot UserName-> -$userName-\n---\n";

            if( $params[$i] eq "of" ){
                $command = $command ." ". $params[$i] ."=". $userName.".img";
                print "ParamsArray[$i]-> $params[$i], $userName\t";
            } else{
                $command = $command ." ". $params[$i] ."=". $defaultValues[$i];
                print "ParamsArray[$i]-> $params[$i], DefaultValuesArray[$i]-> $defaultValues[$i]\t";            
            }
        }
            
        my $arrSize = scalar (@connDevs);
        print "\nArraySize= ".$arrSize."\n";
        if( $j < $arrSize ){
            $command = $command."\n";
        }
        
        $j++;            #current sdX is processed, incrementing...        
        
        $resultingCommand = $resultingCommand.$command;
        print "\n---\nresultingCommand:\n-$resultingCommand-\nj=$j\n";
    }#end foreach conUSBDEVICE loop

    print "\nReturning dd command... j=$j\n";

    if( $j==1 ){
        print "\nNo USB drives are connected!!!\n";
        Wx::MessageBox( "No USB Device is connected, please check that you have a USB Docking Station Plugged-in and try again...", "No USB attached", wxOK|wxCENTRE|wxICON_INFORMATION, );
        return '';
    }
    else{
        return $resultingCommand;    
    }
}

#
# scp -P 19000 -c blowfish -C Disk.img md5.log sha256.log verify.log 
# my @defaultValues = ("/dev/sdX", "Disk.img", "md5,sha256", "md5.log", "sha256.log", "after", "512", "verify.log", "on");
#
sub getSCPcommand{
    my $defaultSCP = "scp -P 19000 -c blowfish -C ".$hashDefaults{"of"}." ".$hashDefaults{"md5log"}." ".$hashDefaults{"sha256log"}." ".$hashDefaults{"verifylog"}." ".$hashDefaults{"username"}."@".$hashDefaults{"hostname"}.":".$hashDefaults{"remoteDir"};

    my $scpCmd="";

    my @connDevs = Deneme::ExampleApp::BoxSizerExampleFrame->getConnectedUSBdevs;
    
    if(@connDevs == 0)
    {
        print "no USB device is attached, returning default/generic scp command";
        Wx::MessageBox( "No USB Device is connected, please check that you have a USB Docking Station Plugged-in and try again...", "No USB attached", wxOK|wxCENTRE|wxICON_INFORMATION, );\
        return $defaultSCP;
    } else{

        for( my $i=0; $i<@connDevs; $i++ ){
            my $curDev = "/dev/".$connDevs[$i];

            # get the PrimaryUsername of the disk from the command
            my $userName = getUserName( $curDev );
    
            print "\n---\nGot UserName-> -$userName-\n---\n";

            $scpCmd = $scpCmd."\nscp -P 19000 -c blowfish -C ".$userName.".img ".$hashDefaults{"md5log"}." ".$hashDefaults{"sha256log"}." ".$hashDefaults{"verifylog"}." ".$hashDefaults{"username"}."@".$hashDefaults{"hostname"}.":".$hashDefaults{"remoteDir"};        
            
            print "\n---\nCurrent SCP command-> -$scpCmd-\n---\n";
        }

        return trimString($scpCmd);
    }
}


#
# Returns the sdX device that is attached to the system through USB
# ( lrwxrwxrwx  1 root root 0 Jun 27 14:09 sdc -> ../devices/pci0000:00/0000:00:1a.7/usb1/1-6/1-6.2/1-6.2:1.0/host7/target7:0:0/7:0:0:0/block/sdc )
#
# return
sub getConnectedUSBdevs {
    my $result = `ls -al /sys/block/ | awk '{if(\$0~/usb/) print \$9}'`;
    $result = trimString( $result ) ;
    
    # Use split(pattern, expression) function to return a array/list of connected USB devices.
    # something like this is returned:
    # @result = ('sdc', 'sdd', 'sde', 'sdf');
    return split(/\s+/, $result);
}

#
#
#    Not using this one yet
#
sub getDevToImageHash {
    my @connDevs = Deneme::ExampleApp::BoxSizerExampleFrame->getConnectedUSBdevs;
    
    for(my $i=0; $i<@connDevs; $i++){

        $USBdevs { $connDevs[$i] } = getUserName( $connDevs[$i] );
    }
    return %USBdevs;
}

#
#
#    Given the dev for USB, return the primary username under /media/XYZXYZ, by ls -alt of Windows/Users folder
#
#
sub getUserName {
    (my $disk) = shift @_ ;    # paramater is expected to be in the form of "/dev/sdc"
    my $userName = "";
    print "\nDisk-> -$disk-\n";
    #
    # my $result = `df | awk '{if($6~/media/ && $6!~/System/){ print "/dev/"substr($1,6,3)"\t"$6; $cmd = "ls -alt "$6"/Users"; system($cmd) }}'`;
    #

    my $mountPoint = `df | grep $disk | awk '{if(\$6 !~/System/) print \$6}'`;

    #$mountPoint = chomp($mountPoint);
    $mountPoint = trimString($mountPoint);

    print "\nCurrent Mount Point->-".$mountPoint."-\n";

    if($mountPoint !~ /media/){
        Wx::MessageBox( "Can't find mount point for $disk under df!!!", "$disk is not mounted", wxOK|wxCENTRE|wxICON_INFORMATION, );
        return "notAvailable";
    }else{
        print "$disk is mounted to $mountPoint\n";
    }
    
    print "----> checking if this is a Windows partition\n\n";

    if(-d "".$mountPoint."/Windows"){
        print "$disk has a Windows Partition...\n";

        my $result = `ls -Alt $mountPoint/Users | awk '{ print \$9}'`;
        my @users = split(/\s+/,$result);

        for( my $i=0; $i < @users; $i++ ){
                    if($users[$i] ne '' && $users[$i] !~/admin/ ){
                $userName = $users[$i];
                            print "returning Main User -".$userName."-\n";
                            last;
                    }
            }
    }
    else{
        print "$disk does NOT have a Windows Partition, we can not find the username, will return the UUID for the partition...\n";
        
        my $mySubDisk = substr($disk,5);
            my $serialNumber = `ls -al /dev/disk/by-id | grep $mySubDisk | awk '{if(\$9!~/part/)print \$9}'`;

        if($serialNumber ne ''){
            my @serialNumbers = split(/\s+/, $serialNumber);
            $serialNumber = $serialNumbers[0];
            print "Serial Number for -$disk- -> -$serialNumber-\n";
            $userName = $serialNumber;        #return harddrive number
        }
        else{
            print "SerialNumber cannot be found for $disk....";
            $userName = "notAvailable";
        }
    }


    return $userName;
}

#
# Trims the whitespaces around the string
#
sub trimString{
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

#
# runs SCP command to transfer the file
#
sub callScp{
    
#    my $scp = Net::SCP->new( { "host"=>$hostname, "user"=>$username } );

#    print $scp->cwd("/home/aliteke/Desktop");

#    my $result = $scp->put("/home/atekeoglu/Downloads/google-earth-stable_current_amd64.deb", "g.deb") or die $scp->{errstr};

#    if($result == 1){
#        print "\nSuccesfully transfered the file\n";
#    }    

    my $result = `scp -c blowfish -C \$defaultValues[1]`;
    $result = trimString( $result ) ;

}

#
# call df shell command
#
sub callDF {

#-- list the processes running on your system
    open(PS,"df |") || die "Failed callDF: $!\n";
    while ( <PS> )
    {
      print $_;
    }
}
1;
