import { LightningElement, track } from 'lwc';

//const PAGE_SIZE = 9;



export default class ProductInterestTesting extends LightningElement {

    @track currentPage = 1;
    pageSize = 12;

    tableData = [
        {
            product: 'Wallets',
            sub_product: 'All Wallets'
            //selectedValue: ''
        },
        {
            product: 'Visa Checkout',
            sub_product: 'VISA CHECKOUT - VIES'
            //selectedValue: ''
        },
        {
            product: 'UPI',
            sub_product: 'Third Party Verification UPI'
           // selectedValue: ''
        },
        {
            product: 'UPI',
            sub_product: 'Intent UPI'
            //selectedValue: ''
        },
        {
            product: 'UPI',
            sub_product: 'Generic UPI'
            //selectedValue: ''
        },
        {
            product: 'Subscriptions',
            sub_product: 'UPI recurring'
            //selectedValue: ''
        },
        {
            product: 'Subscriptions',
            sub_product: 'Enach & SI'
            //selectedValue: ''
        },
        {
            product: 'Rewards',
            sub_product: 'All Pay with Rewards'
           // selectedValue: ''
        },
        {
            product: 'QR',
            sub_product: 'Static BQR'
           // selectedValue: ''
        },
        {
            product: 'QR',
            sub_product: 'Dynamic BQR'
           // selectedValue: ''
        },
        {
            product: 'QR',
            sub_product: 'Offline BQR'
           // selectedValue: ''
        },
        {
            product: 'Other Payment methods',
            sub_product: 'Other Payment methods'
           // selectedValue: ''
        },
        {
            product: 'Net Banking',
            sub_product: 'Third Party Verfication NB'
            //selectedValue: ''
        },
        {
            product: 'Net Banking',
            sub_product: 'Retail Netbanking'
            //selectedValue: ''
        },
        {
            product: 'Net Banking',
            sub_product: 'Corporate NetBanking'
            //selectedValue: ''
        },
        {
            product: 'IVR',
            sub_product: 'IVR DC'
            //selectedValue: ''
        },
        {
            product: 'IVR',
            sub_product: 'IVR'
            //selectedValue: ''
        },
        {
            product: 'International Payments',
            sub_product: 'All International Cards'
            //selectedValue: ''
        },
        {
            product: 'EMI',
            sub_product: 'Credit Card- EMI'
            //selectedValue: ''
        },
        {
            product: 'EMI',
            sub_product: 'Cardlesss- EMI'
            //selectedValue: ''
        },
        {
            product: 'EMI',
            sub_product: 'Debit Card- EMI'
           // selectedValue: ''
        },
        {
            product: 'Direct Bank Transfer',
            sub_product: 'All DBT, IMPS, NEFT and RTGS'
            //selectedValue: ''
        },
        {
            product: 'Debit Card',
            sub_product: 'All Debit Cards'
            //selectedValue: ''
        },
        {
            product: 'Credit card',
            sub_product: 'Other Schemes'
            //selectedValue: ''
        },
        {
            product: 'Credit card',
            sub_product: 'AMEX'
            //selectedValue: ''
        },
        {
            product: 'Credit card',
            sub_product: 'DINERS'
            //selectedValue: ''
        },
        {
            product: 'CNT',
            sub_product: 'NetBanking CNT'
            //selectedValue: ''
        },
        {
            product: 'CNT',
            sub_product: 'UPI CNT'
            //selectedValue: ''
        },
        {
            product: 'CNT',
            sub_product: 'Wallet CNT'
           // selectedValue: ''
        },
        {
            product: 'CNT',
            sub_product: 'Connect CNT'
           // selectedValue: ''
        },
        {
            product: 'CNT',
            sub_product: 'Credit Card CNT'
           // selectedValue: ''
        },
        {
            product: 'CNT',
            sub_product: 'Debit Card CNT'
            //selectedValue: ''
        },
        {
            product: 'Challan Payments',
            sub_product: 'Challan Payments'
            //selectedValue: ''
        },
        {
            product: 'Cash On Delivery',
            sub_product: 'Cash On Delivery'
            //selectedValue: ''
        },
        {
            product: 'BNPL',
            sub_product: 'BNPL'
           // selectedValue: ''
        },
        {
            product: 'Bharat Bill Pay Service',
            sub_product: 'All BBPS Modes'
           // selectedValue: ''
        }
        
    ];

    // tableData = [
    //     {
    //         product: 'Wallets',
    //         sub_product: 'All Wallets',
    //         selectedValue: ''
    //     },
    //     {
    //         product: 'Visa Checkout',
    //         sub_product: 'VISA CHECKOUT - VIES',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'UPI',
    //         sub_product: 'Third Party Verification UPI',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'UPI',
    //         sub_product: 'Intent UPI',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'UPI',
    //         sub_product: 'Generic UPI',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Subscriptions',
    //         sub_product: 'UPI recurring',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Subscriptions',
    //         sub_product: 'Enach & SI',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Rewards',
    //         sub_product: 'All Pay with Rewards',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'QR',
    //         sub_product: 'Static BQR',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'QR',
    //         sub_product: 'Dynamic BQR',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'QR',
    //         sub_product: 'Offline BQR',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'Other Payment methods',
    //         sub_product: 'Other Payment methods',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'Net Banking',
    //         sub_product: 'Third Party Verfication NB',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Net Banking',
    //         sub_product: 'Retail Netbanking',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Net Banking',
    //         sub_product: 'Corporate NetBanking',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'IVR',
    //         sub_product: 'IVR DC',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'IVR',
    //         sub_product: 'IVR',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'International Payments',
    //         sub_product: 'All International Cards',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'EMI',
    //         sub_product: 'Credit Card- EMI',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'EMI',
    //         sub_product: 'Cardlesss- EMI',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'EMI',
    //         sub_product: 'Debit Card- EMI',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'Direct Bank Transfer',
    //         sub_product: 'All DBT, IMPS, NEFT and RTGS',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Debit Card',
    //         sub_product: 'All Debit Cards',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Credit card',
    //         sub_product: 'Other Schemes',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Credit card',
    //         sub_product: 'AMEX',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Credit card',
    //         sub_product: 'DINERS',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'CNT',
    //         sub_product: 'NetBanking CNT',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'CNT',
    //         sub_product: 'UPI CNT',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'CNT',
    //         sub_product: 'Wallet CNT',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'CNT',
    //         sub_product: 'Connect CNT',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'CNT',
    //         sub_product: 'Credit Card CNT',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'CNT',
    //         sub_product: 'Debit Card CNT',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Challan Payments',
    //         sub_product: 'Challan Payments',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'Cash On Delivery',
    //         sub_product: 'Cash On Delivery',
    //         selectedValue: ''
    //         //selectedValue: ''
    //     },
    //     {
    //         product: 'BNPL',
    //         sub_product: 'BNPL',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     },
    //     {
    //         product: 'Bharat Bill Pay Service',
    //         sub_product: 'All BBPS Modes',
    //         selectedValue: ''
    //        // selectedValue: ''
    //     }
        
    // ];

    selectedValue = [];

    connectedCallback() {
        this.initializeSelectedValues();
    }

    // initializeSelectedValues() {
    //     const totalRecords = this.tableData.length;
    //     this.selectedValue = new Array(totalRecords).fill('');
        
    // }
    initializeSelectedValues(){
        const totalPages = Math.ceil(this.tableData.length / this.pageSize);
        for(let i= 0; i < totalPages; i++){
            this.selectedValue.push([]);
        }
    }

    // initializeSelectedValues(){
    //     const totalPages = Math.ceil(this.tableData.length / this.pageSize);
    //     for(let i= 0; i < totalPages; i++){
    //         for(let j= 0; j < totalPages; j++) {
    //             const recordIndex = (i - 1) * this.pageSize + j;
    //             this.selectedValue.set(`${i}-${recordIndex}`, '');
    //         }
            
    //     }
    // }

    

    get visibleRecords() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.tableData.slice(start, end);
    }

    get options() {
        return [
            { label: 'Reason 1', value: 'Reason 1' },
            { label: 'Reason 2', value: 'Reason 2' },
            { label: 'Reason 3', value: 'Reason 3' },
        ];
       
        }

    shouldDisplayRow(index) {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return index >= start && index < end;
    }

    handleChange(event) {
        const { name, value } = event.target.dataset;
        const recordIndex = (this.currentPage - 1) * this.pageSize + parseInt(name, 10);
        this.selectedValue[this.currentPage - 1][recordIndex % this.pageSize] = value;
        this.selectedValue = [...this.selectedValue];
        //this.selectedValue[recordIndex] = value;
        
        //this.selectedValue.set(`${this.currentPage}-${recordIndex}`, value);
        //this.selectedValue[recordIndex] = value;
        //
        //const selectedValuesForPage = this.selectedValue.get(this.currentPage);
        //selectedValuesForPage.set(recordIndex, value);
        //this.selectedValue.set(this.currentPage, new Map(selectedValuesForPage));
        
        //this.selectedValue = new Map(this.selectedValue);
        // if(this.tableData[recordIndex]){
        //     this.tableData[recordIndex].selectedValue = value;
        //     this.tableData = [...this.tableData];
        // }
        //this.updateSelectedValue(recordIndex, value);
        // const updatedRecords = [...this.tableDate];
        // updatedRecords[recordIndex].selectedValue = value;
        // this.tableDate = updatedRecords;
        //this.tableDate = [...this.tableDate];
        //this.tableDate[recordIndex].selectedValue = value;
        //TABLE_DATA[recordIndex].selectedValue = value;
    }

    // updateSelectedValue(index, value){
    //     const updateData = JSON.parse(JSON.stringify(this.tableData));
    //     updateData[index].selectedValue = value;
    //     this.tableData = updateData;
    // }

    goToPreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    goToNextPage() {
        const totalPages = Math.ceil(this.tableData.length / this.pageSize);
        if (this.currentPage < totalPages) {
            this.currentPage++;
        }
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        const totalPages = Math.ceil(this.tableData.length / this.pageSize);
        return this.currentPage === totalPages;
    }

    

}