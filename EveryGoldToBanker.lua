-- Author      : Olivier Pelletier
-- Version : 18/03/2015

local AddOns_name = "EveryGoldToBanker";

RECEIVER = "No receiver";
AMOUNT = 100;
VISIBILITY = "show";
EVERYGOLDTOBANKER_CONFIG2 = {RECEIVER,AMOUNT};

SlashCmdList["EGTB_TOGGLE"] = ToggleEGTBFrame;
SLASH_EGTB_TOGGLE1 = "/egtb";
SLASH_EGTB_TOGGLE2 = "/everygoldtobanker";

function EveryGoldToBankerCalculator_OnLoad()
	EveryGoldToBankerCalculator:RegisterEvent("PLAYER_ENTERING_WORLD");
	EveryGoldToBankerCalculator:RegisterEvent("MAIL_SHOW");
	EveryGoldToBankerCalculator:RegisterEvent("MAIL_CLOSED");
	EveryGoldToBankerCalculator:RegisterEvent("ADDON_LOADED");
	EveryGoldToBankerCalculator:RegisterEvent("PLAYER_LOGOUT");	
	EveryGoldToBankerCalculator:RegisterForDrag("LeftButton");	
end

function EveryGoldToBankerCalculator_OnEvent(frame, event, firstArg, secondArg)
	if (event == "PLAYER_ENTERING_WORLD") then		
		EveryGoldToBankerCalculator:Hide();
	elseif (event == "MAIL_SHOW") then
		if (GameMenuFrame:IsVisible() ~= 1) then
			if (VISIBILITY == "show") then
				EveryGoldToBankerCalculator:Show();
				SettingFrame:Hide();
				AmountEditBox:SetNumber(EVERYGOLDTOBANKER_CONFIG2[2]);
				ReceiverEditBox:SetText(EVERYGOLDTOBANKER_CONFIG2[1]);
				DefaultAmountEditBox:SetNumber(EVERYGOLDTOBANKER_CONFIG2[2]);
				DefaultReceiverEditBox:SetText(EVERYGOLDTOBANKER_CONFIG2[1]);
			end
		end		
	elseif (event == "MAIL_CLOSED") then
		EveryGoldToBankerCalculator:Hide();
	elseif (event == "ADDON_LOADED") then
		if (firstArg == AddOns_name) then
			print("EveryGoldToBanker loaded!");
		end
	end
end

function EveryGoldToBankerCalculator_OnDragStart()
	EveryGoldToBankerCalculator:StartMoving();
end

function EveryGoldToBankerCalculator_OnDragStop()
	EveryGoldToBankerCalculator:StopMovingOrSizing();
end

function CheckButton_OnClick()
	amountToKeep = AmountEditBox:GetNumber()*10000
	amountInBag = GetMoney()
	
	amountToSend = CalculateGoldToSend()
	amountToSendConverted = Convert(amountToSend)	
	
	if (amountToKeep == amountInBag) then
		Response:SetText("You don't have to send money.");
	elseif (amountToSend < 0) then
		Response:SetText("You don't have enough money.");
	else
		Response:SetText("You have to send \n " .. amountToSendConverted);
	end	
end

function SendButton_OnClick()
	amountToKeep = AmountEditBox:GetNumber()*10000
	amountInBag = GetMoney()
	
	tempReceiver = ReceiverEditBox:GetText()
	amountToSend = CalculateGoldToSend()
	amountToSendConverted = Convert(amountToSend)	
	
	MailFrameTab2:Click();		
	
	if (amountToKeep == amountInBag) then
		Response:SetText("You don't have to send money.");
	elseif (amountToSend < 0) then
		Response:SetText("You don't have enough money.");
	else
		if (tempReceiver ~= "No receiver") then
			SetSendMailMoney(amountToSend);
			SendMail(tempReceiver,"EveryMoneyToBanker auto-send system.","");
		else
			Response:SetText("You didn't change the receiver name. CHANGE IT!");
		end
	end
end

function SettingButton_OnClick()
	if(SettingFrame:IsVisible()) then
		SettingFrame:Hide();
	else
		SettingFrame:Show();
	end
end

function DoneSettingButton_OnClick()
	defaultReceiver = DefaultReceiverEditBox:GetText();
	defaultAmount = DefaultAmountEditBox:GetText();
	EVERYGOLDTOBANKER_CONFIG2 = {defaultReceiver, defaultAmount};
	
	AmountEditBox:SetNumber(defaultAmount);
	ReceiverEditBox:SetText(defaultReceiver);
	
	SettingFrame:Hide();
end

function Convert(amountToConvert)
	amountString = "" .. amountToConvert
	length = strlen(amountString)
	
	copper = "" .. strsub(amountString,length-1,length)
	silver = "" .. strsub(amountString,length-3,length-2)
	gold = "" .. strsub(amountString,length-(length-1),length-4)
	
	if (amountToConvert < 10000) then
		amountConverted = "" .. silver .. " s. " .. copper .. " c."
	elseif (amountToConvert < 100) then
		amountConverted = "" .. copper .. " c."
	else
	amountConverted = "" .. gold .. " g. " .. silver .. " s. " .. copper .. " c."
	end
	
	return amountConverted
end

function CalculateGoldToSend()
	amountToKeep = AmountEditBox:GetNumber()*10000
	amountInBag = GetMoney()
	sendPrice = GetSendMailPrice()
	
	amountToSend = amountInBag-amountToKeep-sendPrice
	
	return amountToSend
end

function ToggleEGTBFrame()
	if (VISIBILITY == "show") then
		VISIBILITY = "hide"
		EveryGoldToBankerCalculator:Hide();
		print("EGTB toggled (hide)");
	elseif (VISIBILITY == "hide") then
		VISIBILITY = "show"
		if (MailFrame:IsVisible()) then
			EveryGoldToBankerCalculator:Show();			
		end
		print("EGTB toggled (show)");
	end
end