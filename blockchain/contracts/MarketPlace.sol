// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract Marketplace is ERC721, ERC721URIStorage, Ownable {
    constructor() payable ERC721("Marketplace", "MK") {
        
    }

    address public constant MarketplaceVaultAddress = 0x909957dcc1B114Fe262F4779e6aeD4d034D96B0f;
    
    event ItemCreated(uint indexed _id, address indexed seller, uint indexed price);
    event ItemSold(uint indexed _id, address indexed buyer, uint indexed amount);
    event SellerWithdraw(uint indexed amount, address indexed withdrawer);
    event OrderStatusUpdated(ShippingStatus ShippingStatus, uint indexed id, address indexed seller, address indexed buyer);



    uint public currentId;

    
    //address of user points to array of items created
    mapping(address => uint[]) public createdByUser;
    //address of user points to array of items bought;
    mapping(address => uint[]) public boughtByUser;

    // address of user pointing to ID of item pointing to the sale price of ID of item
    mapping(address => mapping(uint => uint)) public userInventory;
    //uint (ID) points to shipping status
    mapping(uint => ShippingStatus) public orderStatus;
    // balance of user, address points to value
    mapping(address => uint) public balanceUser;
    // id points to buyer;
    mapping(uint => address) public buyerOfId;
    // id points to sold status;
    mapping(uint => bool) public SoldStatus;
    
    


    address[] public sellers;

   enum ShippingStatus {
       OrderNotActive,
       OrderReceived,
       ShippingInProgress,
       Shipped
   }

    function CreateItemToSell(uint sellPrice, string memory tokenUri) public payable {
        require(sellPrice != 0, "Price can't be 0");
        setApprovalForAll(address(this), true);
        currentId++;
        userInventory[msg.sender][currentId] = sellPrice;
        _mint(msg.sender, currentId);
        sellers.push(msg.sender);
        SoldStatus[currentId] = false;
        _setTokenURI(currentId, tokenUri);
        createdByUser[msg.sender].push(currentId);
        emit ItemCreated(currentId, msg.sender, sellPrice);
    }

    function BuyItem(uint _id, address seller) public payable {
       require(msg.value  == userInventory[seller][_id], "inssuficient ammount");
       require(ownerOf(_id) == seller, "seller is not owner of Id" );
       ERC721(address(this)).safeTransferFrom(seller, msg.sender, _id);
       orderStatus[_id] = ShippingStatus.OrderReceived;
       balanceUser[seller] += msg.value;
       buyerOfId[_id] = msg.sender;
       SoldStatus[_id] = true;
       boughtByUser[msg.sender].push(_id);
       emit ItemSold(_id, msg.sender, msg.value);
    }

    function withDrawMarketplace() external onlyOwner {
         uint256 _balance = address(this).balance;
        (bool sent, bytes memory data) = MarketplaceVaultAddress.call{value: _balance}("");
        require(sent, "Failed to send Ether");
    }

    function withDrawSeller() external payable {
        require(balanceUser[msg.sender] > 0, "Required to have funds");
        uint256 _balance = balanceUser[msg.sender];
        uint256 percent = _balance / 100;
        balanceUser[msg.sender] = 0;
        (bool sent, bytes memory data) = msg.sender.call{value: percent * 95}("");
        require(sent, "Failed to send Ether");
    }


    function getSalePrice(address seller, uint _id) external view returns(uint) {
         uint salePrice = userInventory[seller][_id];
         return salePrice;
    }

    function getUserBalance(address user) external view returns(uint) {
        uint userBalance = balanceUser[user];
        return userBalance;
    }

    function forIdGetSellerAndPrice(uint _id) external view returns (address, uint) {
          uint sellerArrayLen = sellers.length;
          for(uint i = 0; i <= sellerArrayLen; i++) {
            uint price = userInventory[sellers[i]][_id];
               if(price > 0 ) {
                return (sellers[i], price);
               } 
          }
    }

    function getShipmentStatusForId(uint _id) external view returns(ShippingStatus shippingStatus) {
       shippingStatus = orderStatus[_id];
       return shippingStatus;
    }

    function updateShipmentStatus(uint _id) external {
        require(userInventory[msg.sender][_id] > 0, "user doesn't own the item");
        orderStatus[_id] = ShippingStatus.ShippingInProgress;
        emit OrderStatusUpdated(ShippingStatus.ShippingInProgress, _id, msg.sender, buyerOfId[_id]);
    }

      function finalizeOrder(uint _id) external {
        require(userInventory[msg.sender][_id] > 0, "user doesn't own the item");
        orderStatus[_id] = ShippingStatus.Shipped;
        emit OrderStatusUpdated(ShippingStatus.Shipped, _id, msg.sender, buyerOfId[_id]);
    }

    function getItemIdsCreatedByUser(address user) public view returns (uint[] memory) {
     return createdByUser[user];
    }

     function getItemIdsBoughtByUser(address user) public view returns (uint[] memory) {
     return boughtByUser[user];
    }




    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
  
 
        function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

     function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

}

