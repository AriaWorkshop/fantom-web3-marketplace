import React from 'react'
import { useEffect } from 'react'
import axios from 'axios'

const RecentlyCreated = () => {

  async function callForRecentlyCreated(){
    const headers = {
      'accept': 'application/json',
      'X-API-Key': `${process.env.NEXT_PUBLIC_MORALIS_API_KEY}`,
      'content-type': 'application/json'
    };
    
    const data ={"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"_id","type":"uint256"},{"indexed":true,"internalType":"address","name":"seller","type":"address"}],"name":"ItemCreated","type":"event"};
    
    axios.post(
      'https://deep-index.moralis.io/api/v2/0x162A384D5183c6e8A48d5fE0F84109E2d0079A73/events?chain=fantom&from_block=55587828&topic=0x1c78b9707d8ddf8078f46413765b0e73d250ffc795526eeb39c6889ea8efafd0',
      data,
      { headers }
    )
    .then(response => {
      console.log(response.data);
    })
    .catch(error => {
      console.error(error);
    });
  }

  useEffect(() => {
   
  }, [])


    
  return (
    <div>
        <div className='grid grid-cols-4 justify-items-center '>
             <div className=''>
             recentlyCreated
             </div>
             <div>
             recentlyCreated
             </div>
             <div>
             recentlyCreated
             </div>
             <div>
             recentlyCreated
             </div>
        </div>
        <div>
     
        </div>
    </div>
  )
}

export default RecentlyCreated