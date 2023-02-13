import React from 'react'
import { useEffect } from 'react';
import axios from 'axios';
import { useState } from 'react';
import { useIsMounted } from '@/hooks/useIsMounted';
import { connectorsForWallets } from '@rainbow-me/rainbowkit';

const CreatedByUserCard = (props) => {


     const [eventsData, setEventsData] = useState([]);
     const [stateOfArray, setstateOfArray] = useState(false);
      
    
let initialArr = [];


    function filterData(arg) {
        console.log(arg + " " + "this is props")
      
            for(let i = 0; i < initialArr.length; i++) {
                if(arg.toLowerCase() == initialArr[i].seller.toLowerCase()) {
                    eventsData.push(initialArr[i]);
                console.log("this is user events")
                setstateOfArray(true)
                } else {
                  console.log('fail')
                }
    
    
        }
       
    }

    async function callForRecentlyCreated(){
        const headers = {
          'accept': 'application/json',
          'X-API-Key': `${process.env.NEXT_PUBLIC_MORALIS_API_KEY}`,
          'content-type': 'application/json'
        };
        
        const data ={"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"_id","type":"uint256"},{"indexed":true,"internalType":"address","name":"seller","type":"address"}],"name":"ItemCreated","type":"event"};
        
       await axios.post(
          'https://deep-index.moralis.io/api/v2/0x2853CB399033447AAf3A14c8c4bC41Be43c0856e/events?chain=fantom&from_block=55587828&topic=0x1c78b9707d8ddf8078f46413765b0e73d250ffc795526eeb39c6889ea8efafd0',
          data,
          { headers }
        )
        .then(response => {
         
            for (let i = 0; i < response.data.result.length; i++) {
            initialArr.push(response.data.result[i].data);
            console.log(initialArr)
            }
            
            filterData(props.routeWallet)
        
        })
        .catch(error => {
          console.error(error);
        });
      }
      
  
    
      useEffect(() => {
      setTimeout(() => {
        callForRecentlyCreated();
        console.log(props.routeWallet + " " + "this is in useEffect")
     
      }, 500)  
       
      }, [props.routeWallet, eventsData, props])

        
      return (
        <div>
          {stateOfArray ? eventsData.map(event => (
          <div>
            <p>{event.seller}</p>
            <p>{event._id}</p>
         </div>
        )) : <div>null</div>}
          
            <div>
         
            </div>
        </div>
      )
    }

export default CreatedByUserCard