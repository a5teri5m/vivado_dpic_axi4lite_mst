`default_nettype none
module axi4l_slv # (
    parameter         INST_NAME      = "u_axi4l_slv"
) (
    input  wire         axi_aclk,
    input  wire         axi_aresetn,

    input  wire [31:0]  s_axi_awaddr, 
    input  wire [2:0]   s_axi_awprot, 
    input  wire         s_axi_awvalid,
    output reg          s_axi_awready,
    input  wire [31:0]  s_axi_wdata,  
    input  wire [3:0]   s_axi_wstrb,  
    input  wire         s_axi_wvalid, 
    output reg          s_axi_wready, 
    output reg  [1:0]   s_axi_bresp,  
    output reg          s_axi_bvalid, 
    input  wire         s_axi_bready,
    input  wire [31:0]  s_axi_araddr,
    input  wire [2:0]   s_axi_arprot,
    input  wire         s_axi_arvalid,
    output reg          s_axi_arready,
    output reg  [31:0]  s_axi_rdata,
    output reg  [1:0]   s_axi_rresp,
    output reg          s_axi_rvalid,
    input  wire         s_axi_rready
);

    localparam ADDR_MASK = 32'h0000_FFFF;

    reg  [31:0] slv_awaddr, slv_araddr, slv_rdata;
	wire slv_rd_en, slv_wr_en;



    // awready
    always @(posedge axi_aclk) begin
	    if (axi_aresetn == 1'b0) begin
	        s_axi_awready <= 1'b0;
	    end else begin    
	        if (~s_axi_awready && s_axi_awvalid && s_axi_wvalid) begin
	            s_axi_awready <= 1'b1;
	        end else begin
	            s_axi_awready <= 1'b0;
	        end
	    end 
	end       

    // awaddr
	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 1'b0) begin
	        slv_awaddr <= 32'b0;
	    end else begin    
	        if (~s_axi_awready && s_axi_awvalid && s_axi_wvalid) begin
	            slv_awaddr <= s_axi_awaddr;
	        end
	    end 
	end       


    // wready
	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 1'b0) begin
	        s_axi_wready <= 1'b0;
	    end else begin    
	        if (~s_axi_wready && s_axi_wvalid && s_axi_awvalid) begin
	            s_axi_wready <= 1'b1;
	        end else begin
	            s_axi_wready <= 1'b0;
	        end
	    end 
	end       
    
	assign slv_wr_en = s_axi_wready && s_axi_wvalid && s_axi_awready && s_axi_awvalid;

    // wren
	always @(posedge axi_aclk) begin
        if (slv_wr_en == 1'b1) begin
            $strobe("%t: [%s] WR ( ADDR=%H, DATA=%H )", $time, INST_NAME, slv_awaddr, s_axi_wdata);
        end
	end    


    // bvalid, bresp
	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 1'b0) begin
	        s_axi_bvalid  <= 0;
	        s_axi_bresp   <= 2'b0;
	    end else begin    
	        if (s_axi_awready && s_axi_awvalid && ~s_axi_bvalid && s_axi_wready && s_axi_wvalid) begin
	            s_axi_bvalid <= 1'b1;
	            s_axi_bresp  <= 2'b0;
	        end else begin
	            if (s_axi_bready && s_axi_bvalid) begin
	                s_axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

    // arready, araddr
	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 1'b0) begin
	        s_axi_arready <= 1'b0;
	        slv_araddr  <= 32'b0;
	    end else begin    
	        if (~s_axi_arready && s_axi_arvalid) begin
	            s_axi_arready <= 1'b1;
	            slv_araddr  <= s_axi_araddr;
	        end else begin
	            s_axi_arready <= 1'b0;
	        end
	    end 
	end       


    // rvalid, rrsep
	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 1'b0) begin
	        s_axi_rvalid <= 0;
	        s_axi_rresp  <= 0;
	    end else begin    
	        if (s_axi_arready && s_axi_arvalid && ~s_axi_rvalid) begin
	            s_axi_rvalid <= 1'b1;
	            s_axi_rresp  <= 2'b0;
	        end else if (s_axi_rvalid && s_axi_rready) begin
	            s_axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	assign slv_rd_en = s_axi_arready & s_axi_arvalid & ~s_axi_rvalid;

    always @(axi_aclk) begin
        slv_rdata <= $random;
    end

	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 1'b0) begin
	        s_axi_rdata  <= 0;
	    end else begin    
	        if (slv_rd_en) begin
	            s_axi_rdata <= slv_rdata;
                $strobe("%t: [%s] RD ( ADDR=%H, DATA=%H )", $time, INST_NAME, slv_araddr, s_axi_rdata);
	        end   
	    end
	end    



endmodule
`default_nettype wire

