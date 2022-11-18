//SPDX Licence
//Source
//https://www.youtube.com/watch?v=s9MVkHKV2Vw


pragma solidity ^0.8.9;


// ---------------------------  Do NOT use for MAINNET!--------------------

// The following code is tested, it allows to create customer for the smart contract. 
// Allows to send ETH to the smart contract and it is added to the Balance of customer in the smart contract.
// Allows only the customer to withdraw his ETH, but everyone to send customers some.
// Also it is possible to get the balance of the total contract.
// All further steps are in the next file. 


contract tokenBasket{



    address     owner;                              // person who deploys the smart contract

   // address     public immutable customer;           // customer = person how sends ETH to smart contract
    uint        public customer_send_Eth_Value;      // amount of sent ETH from customer to smart contract
    uint        public half_of_customer_send_Eth_Value;

    // defined once when smartcontract is deployed;
    constructor() {
        owner = msg.sender; // msg.sendeeraddress of sender
    }

  
    //defining assets in the basket 50% USDT / 50% USDC
    //self implemented defined address for USDC , USDT

    // address private constant USDC = xxxxxxxxxxxxxxxxxxxxxxxxxx;         //CHANGE

    //address private constant USDT = xxxxxxxxxxxxxxxxxxxxxxxxxx;         //CHANGE
    
    // As said before, our smart contract only accepts native ETH.
    // We need the address of the ETH for our swap function.
    
    //  address private constant Native_ETH = xxxxxxxxxxxxxxxxxxxxxxxxxx;     //CHANGE
    //address address_of_our_smart_contract; // CHANGE 


    // will work with array not mapping


    // Define what a customer is.
    // struct = collection of variables under a single name
    // define a customer

    struct customer {
        address     payable walletAddress;           // address of customer
        uint                amount;                 // value the customer has sended in ETH
        uint                amount_usdc;
        uint                amount_usdt;
    }

    // we will have multiple customers so we create an array
    customer[] public customers_array; // array of type customer and the array is called customer_array



    function addCustomer(address payable walletAddress, uint amount, uint amount_usdc, uint amount_usdt) public {
        //amount can be set by everyone, so when a new customer gets deployed it will be always 
        // set the amount to Zero. 
        amount = 0 ;
        amount_usdc = 0;
        amount_usdt = 0;

        customers_array.push(customer(
            walletAddress,
            amount, 
            amount_usdc,
            amount_usdt
            ));
    }




  // everyone can send funds to a specifc customers holdings in the smartcontract.
    // deposits funds to the contract, but specifically to the customer account
    function addToCustomersBalance(address walletAddress)private {
        // go over the whole array an check for the address
        for (uint i = 0 ; i < customers_array.length; i++){
            // if customer is already in the list, add the value he sent from his address
            // to the amount that is already in 
            if (customers_array[i].walletAddress == walletAddress){
                customers_array[i].amount += msg.value;

            }
        }
    }


    
    // allows to send funds to smart contract
    function deposit(address walletAddress) payable public{
        addToCustomersBalance(walletAddress);
    
        }


 // get balance of the whole contract 
    function balanceOfContract() public view returns (uint) {
        return address(this).balance;
    }


//function to find the index of the customer , where the wallet address is the same
    function getIndex(address walletAddress) view private returns(uint){
        for(uint i = 0; i < customers_array.length; i++){
            if (customers_array[i].walletAddress == walletAddress){
                return i;
            }
        }
        return 9999999999999999999; // the function can only return uint, so we cannot put any negative numbers
    }

     //withdraw money, only the owner of the address can withdraw his/her own money
    function withdraw(address payable walletAddress) payable public{

        uint i = getIndex(walletAddress);

        //only aviailabe to get your own money, not the money of other customers
        require(msg.sender == customers_array[i].walletAddress, "You should be the owner of the wallet!");


        //transfer is for sending funds. We use this because not all the funds of the contract  will be sent, only the 
        //amount of funds that the customer owns in the smart contract.
        customers_array[i].walletAddress.transfer(customers_array[i].amount);


    }
}






