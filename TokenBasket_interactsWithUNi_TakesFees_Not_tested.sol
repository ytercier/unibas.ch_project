//SPDX Licence
//Source
//https://www.youtube.com/watch?v=s9MVkHKV2Vw


pragma solidity ^0.8.9;



//----------------------Do NOT use for mainnet!!!--------------------

// Problems:
//We were not able to test the whole contract in Goerli testnet, could not find the address for USDC and USDT. 
//Also we couldnot find out what address uniswap has in Goerli.

// ------------------------- Description of the Contract -------------------

// Our basket works with USDC and USDT tokens (50%/50%).
// The basket would be perfect for someone who wants to Dollar cost average in multiple tokens because he would save on gas fees.
// USDT and USDT are just used as an example, of course to dollar cost average with ETH into USDT / USDC makes no sense :D.

// Owner (who deployed the contract) of the tokenbasket will get 1%.
// first customer that needs to be added is the owner, that he is able to get the 1 % on his name.

//Customer can add himself as a customer, when he sends ETH to the contract, he is able to swap the ETH he sends for USDC and USDT, the contract is holing them for him.
//also the customer can swap the USDC and USDT back for ETH, and withdraw the ETH from the contract. No withdrawal of USDC or USDT.

// Future added features: smart contract swaps only every 24 hours, each swap request from the customer will be added automatically to the queue.
// The received funds from the swaps will be added to the customers' amounts/balances. 
// In this way the gas fees for the operation will be reduced. Because not every customer needs to pay gas for each swap.

// For now it is not solved how the gas fees will be payed. For the future planned, the gasfees for the swap will be payed 
//from the owners balance/amount what is in the smart contract.




//     ->>>>>   Imports    <<<<<--

//import the ERC20 interface

//--------------------------------- The following Code is a COPIE.  *  --------------------------------
                // * have applyied some changes to the swap function. THe rest is a Copie.

//Source: https://cryptomarketpool.com/how-to-swap-tokens-on-uniswap-using-a-smart-contract/
// The Code is copied, that our smart contract is able to make swaps with the dex called uniswap.

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


//import the uniswap router
// Source https://cryptomarketpool.com/how-to-swap-tokens-on-uniswap-using-a-smart-contract/

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(
  
    //amount of tokens we are sending in
    uint256 amountIn,
    //the minimum amount of tokens we want out of the trade
    uint256 amountOutMin,
    //list of token addresses we are going to trade in.  this is necessary to calculate amounts
    address[] calldata path,
    //this is the address we are going to send the output tokens to
    address to,
    //the last time that the trade is valid for
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}

//  ------->   End of uniswap Router import  <---------



// contract to Swap tokens using Uniswap(decentralized exchange)
// What is wrapped Eth? Eth = coin = Native asset on Ethereum, WEth = wrapped Eth = Eth like ERC 20 (token)
contract tokenSwap {
    
    //address of the uniswap v2 router              // Still need to CHANGE the address to address of testnet !!!
    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    
    //address of WETH token.  This is needed because sometimes it is better to trade through WETH.  
    //you might get a better price using WETH.  
    //example trading from token A to WETH then WETH to token B might result in a better price
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
                                // Still need to CHANGE the address to testnet address!!
    
    address private constant USDC = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;  // Change

    adress private constant USDT = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;  // Change


    //this swap function is used to trade from one token to another
    //the inputs are self explainatory
    //token in = the token address you want to trade out of  ----> IN OUR CASE IT WILL BE ALWAYS THE SAME, maybe Eth. still needs to be defined
    //token out = the token address you want as the output of this trade
    //amount in = the amount of tokens you are sending in ---> in our case half of the _customer_send_Eth_Value;
    //amount out Min = the minimum amount of tokens you want out of the trade
    //to = the address you want the tokens to be sent to
    
   function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to, customer_send_Eth_Value) external {
      
    //first we need to transfer the amount in tokens from the msg.sender to this contract
    //this contract will have the amount of in tokens
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    
    //next we need to allow the uniswapv2 router to spend the token we just sent to this contract
    //by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract 
    IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

    //path is an array of addresses.
    //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
    //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
    address[] memory path;
    if (_tokenIn == WETH || _tokenOut == WETH) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    }
        //then we will call swapExactTokensForTokens
        //for the deadline we will pass in block.timestamp
        //the deadline is the latest time the trade is valid for
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }
    
       //this function will return the minimum amount from a swap
       //input the 3 parameters below and it will return the minimum amount out
       //this is needed for the swap function above
     function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256) {

       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
       //the if statement below takes into account if token in or token out is WETH. Then the path is only 2 addresses
        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }
        
        uint256[] memory amountOutMins = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }  
}







//                                  ---------> End of Imports  <-----------


//-------------------------------------> End of Copie of Code   <-------------------------------



//      -----------------------  All the following Code is self-written   -----------------

                                           
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



// will work with array not mapping


    // Define what a customer is.
    // struct = collection of variables under a single name
    // define a customer
    struct customer {
        address     payable walletAddress;           // address of customer
        uint                amount;                 // value the customer has sent in ETH
        uint                amount_usdc;
        uint                amount_usdt;
    }

    // we will have multiple customers so we create an array
    customer[] public customers_array; // array of type customer and the array is called customer_array



    // We did not use modifiers, all the requirement are put directly in the functions



    function addCustomer(address payable walletAddress, uint amount, uint amount_usdc, uint amount_usdt) public {
        // amount above in the function, can be set by everyone, so when a new customer get deployed it will be always 
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


  // everyone can send funds to a specifc customers holdings in the smart contract.
    // deposits funds to the contract, but specifically to the customer account
    // first customer that will be there will be the owner himself, because he wants to get the fees.
    // fee for using our tokenbasket is 1 % .

    function addToCustomersBalance(address walletAddress)private {

    
        // go over the whole array an check for the address
        for (uint i = 0 ; i < customers_array.length; i++){
            // if customer is already in the list, add the value he sent from his address
            // to the amount that is already in 
            if (customers_array[i].walletAddress == walletAddress){
                //adding fees for using smart contract,99 % of value will be added to balance/amount of customer
                costomer_receives_after_fees = ((msg.value / 100)*99);
                customers_array[i].amount += costomer_receives_after_fees;

                // 1 % is going to the owner's account
                owner_of_smartcontract_receives_fees = ((msg.value /100 )*1);
                owner_index = getIndex(owner);
                customers_array(owner_index).amount += owner_of_smartcontract_receives_fees;

            }
           
        }
    }
    

    
    // allows to send funds to smart contract
    function deposit(address walletAddress) payable public{
        addToCustomersBalance(walletAddress);
    
        }


    //read state of the amount the custumers have in all accounts
    //view means no gas cost
    // balance of the total contract!
    function balanceOf() public view returns(uint){
        return address(this).balance;
    }



    //function to find the index of the customer , where the wallet address is the same
    function getIndex(address walletAddress) view private returns(uint){
        for(uint i = 0; i < customers_array.length; i++){
            if (customers_array[i].walletAddress == walletAddress){
                return i;
            }
        }
        return 9999999999999999999; // if it is not in the array, it returns 9999999999... 
    }

     //withdraw money. Only the owner of the address can withdraw his own money
    function withdraw(address payable walletAddress) payable public {

        uint i = getIndex(walletAddress);

        //only aviailabe to get your own money, not the money of other customers 
        //owner of smart contract is also able to withdraw customer funds.
        require(msg.sender == customers_array[i].walletAddress, "You should be the owner of the wallet!");


        //transfer is for sending founds. Not all the funds of the contract will be sent, only the 
        //funds of what this one customer has in the smart contract.
        customers_array[i].walletAddress.transfer(customers_array[i].amount);


    }
}

 

 // now that the contract has received the ETH, and the sent amount is assigned to the customer's balance,
    // We will call the "swap" function, the smart contracts swaps first 0.5 * customer.amount
    // We store the tokens' addresses in the same smart contract 

    // explain swap function
    //swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
    //token in       =  Native_ETH                = ETH address, we wont allow any other tokens 
    //token out      =    USDC                    = the token address you want as the output of this trade -> first trade USDT, second USDC.
    //amount in      =  half_of_customer_send_Eth_Value  = the amount of tokens you are sending in ---> in our case HALF of the sent customer_send_Eth_Value;
    //amount out Min =  the minimum amount of tokens you want out of the trade
    //to             =  address_of_our_smart_contract = the address you want the tokens to be sent to

    //First swap of 50 % of Customer amount for USDC
    
    

    //------------------------- Start swap ETH to USDC / USDT------------------------------------

    //Not solved questions: who is going to pay the gas fees? 
    //How to incorporate two contracts in one solidity file?




    // function for doing the first swap 50% of the ETH into USDC. USDC goes to smart contract, but is added to balance of the original customer.
    function Swap_For_USDC (address Native_ETH, address USDC, uint half_of_customer_send_Eth_Value, uint _amountOutMin, address address_of_our_smart_contract, address customer_send_Eth_Value) external{
         
        // Native_eth, USDC and USDT are constant are also defined  // change
        require Native_ETH == xxxxxxxxxxxx;  Change // token addresses we could not find for the testnet
        require USDC       == xxxxxxxxxxxx;  Change // Troubles finding the correct testnet address for USDC etc. , need the one uniswap works with on Goerli
        require USDT       == xxxxxxxxxxxx;  Change
        require address_of_our_smart_contract == address(this); // address of our smart contract; 


        //check if the customer is already indexed / in the custumer array.
        require (getIndex(customer_send_Eth_Value) != 9999999999999999999, "you are not a custumer yet");

        //after checking the requirements, call she swap function with the parameters given. Basicly do the swap.
        swap(address Native_ETH, address USDC, uint half_of_customer_send_Eth_Value, uint _amountOutMin, address address_of_our_smart_contract, address customer_send_Eth_Value);

        // get the index of the customer
        uint i = getIndex(customer_send_Eth_Value);

        //check if half_of_customer_send_Eth_Value == 0.5 * amount of this customer_send_Eth_Value
        require half_of_customer_send_Eth_Value / 2 == custumers_array[i].amount ;

        //reduce amout of ETH to custumers name  -> - 50 %
        customers_array[i].amount = customers_array[i].amount / 2;

        //assign the amount_usdc of the swap to the customer
        customers_array[i].amount_usdc = amountOutMin;
         
    }

    // function to swap 50% of the ETH the customer sent with sending it to uniswap and swap for USDT, and add received USDT to balance of customer.
    function Swap_for_USDT (address Native_ETH, address USDT, uint half_of_customer_send_Eth_Value, uint _amountOutMin, address address_of_our_smart_contract, address customer_send_Eth_Value) external{
               // Native_eth, USDC and USDT are constant are also defined  // change
        require Native_ETH == xxxxxxxxxxxx;  Change // token addresses we could not find for the testnet
        //require USDC       == xxxxxxxxxxxx;  Change // Troubles finding the correct testnet address for USDC etc. , need the one uniswap works with on Goerli
        require USDT       == xxxxxxxxxxxx;  Change
        require address_of_our_smart_contract == address(this); // address of our smart contract; 
        
        //check if the customer is already indexed/ in the custumer array.
        require (getIndex(customer_send_Eth_Value) != 9999999999999999999, "you are not a custumer yet");
        
        //after checking the requirements, call she swap function with the parameters given. Basicly do the swap.
        swap(address Native_ETH, address USDT, uint half_of_customer_send_Eth_Value, uint _amountOutMin, address address_of_our_smart_contract, address customer_send_Eth_Value);

        // get the index of the customer
        uint i = getIndex(customer_send_Eth_Value);
        //check if half_of_customer_send_Eth_Value == 0.5 * amount of this customer_send_Eth_Value
        require half_of_customer_send_Eth_Value / 2 == custumers_array[i].amount ;

        //reduce amout of eth to custumers name  -> - 50 %
        customers_array[i].amount = customers_array[i].amount / 2;

        //assign the amount_usdc of the swap to the customer
        customers_array[i].amount_usdt = amountOutMin;
        
        }


    //------------------------- END      swap ETH to USDC / USDT-----------------------------


    // //------------------------- Start swap USDC / USDT back to ETH -----------------------

    // function swap back , USDC  for  ETH.
    function Swap_Back_USDC_into_Eth(address Native_ETH, address USDC, uint usdc_amount_Of_Customer, uint _amountOutMin, address address_of_our_smart_contract, address customer_send_Eth_Value) external{
        // Native_eth, USDC and USDT are constant are also defined  // change
        require Native_ETH == xxxxxxxxxxxx;  Change // token addresses we could not find for the testnet
        require USDC       == xxxxxxxxxxxx;  Change // Troubles finding the correct testnet address for USDC etc. , need the one uniswap works with on Goerli
        //require USDT       == xxxxxxxxxxxx;  Change
        require address_of_our_smart_contract == address(this); // adress of our smart contract; 
        
        //check if the customer is already indexed/ in the custumer array.
        require (getIndex(customer_send_Eth_Value) != 9999999999999999999, "You are not a custumer yet.");
        
        //after checking the requirements, call she swap function with the parameters given. Basicly do the swap USDT into ETH
        swap(address USDC, address Native_ETH, uint usdc_amount_Of_Customer , uint _amountOutMin, address address_of_our_smart_contract, address customer_send_Eth_Value);

        // get the index of the customer
        uint i = getIndex(customer_send_Eth_Value);

        //check if usdc_amount_of_customer == safe balance of the customer, cant spend more than he has on his name/address, and only exaclty the whole amount
        require usdc_amount_Of_Customer == custumers_array[i].amount_usdc ;

        //set amount of USDC of customer to zero customer
        customers_array[i].amount_usdc = 0;

        //assign the amount(amount of received ETH) because of the swap to the customer
        customers_array[i].amount = amountOutMin;
        
        }



    // function swap back , USDT for receiving ETH.
    function Swap_Back_USDT_into_Eth(address Native_ETH, address USDT, uint usdt_amount_Of_Customer, uint _amountOutMin, address address_of_our_smart_contract, address customer_send_Eth_Value) external{
        // Native_eth, USDC and USDT are constant are also defined  // change
        require Native_ETH == xxxxxxxxxxxx;  Change // token addresses we could not find for the testnet
        //require USDC       == xxxxxxxxxxxx;  Change // Troubles finding the correct testnet address for USDC etc. , need the one uniswap works with on Goerli
        require USDT       == xxxxxxxxxxxx;  Change
        require address_of_our_smart_contract == address(this); // adress of our smart contract;  
        
        //check if the customer is already indexed/ in the custumer array.
        require (getIndex(customer_send_Eth_Value) != 9999999999999999999, "You are not a custumer yet.");
        
        //after checking the requirements, call she swap function with the parameters given. Basicly do the swap USDT into ETH
        swap(address USDT, address Native_ETH, uint usdt_amount_Of_Customer , uint _amountOutMin, address address_of_our_smart_contract, address customer_send_Eth_Value);

        // get the index of the customer
        uint i = getIndex(customer_send_Eth_Value);

        //check if usdt_amount_of_customer == safe balance of the customer, cant spend more than he has on his name/address, and only exaclty the whole amount
        require usdt_amount_Of_Customer == custumers_array[i].amount_usdt ;

        //set amount of usdt of customer to zero customer
        customers_array[i].amount_usdt = 0;

        //assign the amount(amount of received ETH) because of the swaop to the customer
        customers_array[i].amount = amountOutMin;
        
        }



        // //------------------------- END swap USDC / USDT back to ETH -----------------------
        // Thank you for your attention!
}
 
 




