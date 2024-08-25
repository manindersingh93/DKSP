// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26;

contract KnowledgeSharingPlatform {
    struct Content {
        uint256 id;
        string title;
        string description;
        string contentHash; // Hash of the content stored off-chain (IPFS or similar)
        address payable owner;
        uint256 price;
        uint256 purchaseCount;
    }

    uint256 public contentCounter;
    mapping(uint256 => Content) public contents;
    mapping(uint256 => mapping(address => bool)) public contentPurchasers;

    event ContentAdded(uint256 contentId, string title, address owner, uint256 price);
    event ContentPurchased(uint256 contentId, address buyer);

    // Function to add new content
    function addContent(
        string memory _title,
        string memory _description,
        string memory _contentHash,
        uint256 _price
    ) public {
        require(_price > 0, "Price must be greater than zero");

        contentCounter++;
        contents[contentCounter] = Content(
            contentCounter,
            _title,
            _description,
            _contentHash,
            payable(msg.sender),
            _price,
            0
        );

        emit ContentAdded(contentCounter, _title, msg.sender, _price);
    }

    // Function to purchase content
    function purchaseContent(uint256 _contentId) public payable {
        Content storage content = contents[_contentId];

        require(_contentId > 0 && _contentId <= contentCounter, "Content does not exist");
        require(msg.value >= content.price, "Insufficient payment");
        require(!contentPurchasers[_contentId][msg.sender], "Content already purchased");

        content.owner.transfer(msg.value);
        content.purchaseCount++;

        contentPurchasers[_contentId][msg.sender] = true;

        emit ContentPurchased(_contentId, msg.sender);
    }

    // Function to retrieve content details
    function getContent(uint256 _contentId) public view returns (
        uint256 id,
        string memory title,
        string memory description,
        string memory contentHash,
        address owner,
        uint256 price,
        uint256 purchaseCount
    ) {
        Content storage content = contents[_contentId];

        id = content.id;
        title = content.title;
        description = content.description;
        contentHash = content.contentHash;
        owner = content.owner;
        price = content.price;
        purchaseCount = content.purchaseCount;
    }

    // Function to check if a user has purchased content
    function hasPurchased(uint256 _contentId, address _user) public view returns (bool) {
        return contentPurchasers[_contentId][_user];
    }
}
