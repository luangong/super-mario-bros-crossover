package com.smbc.graphics
{
	import com.smbc.characters.Bill;

	import flash.display.MovieClip;

	public class BillLegs extends SubMc
	{
		private var bill:Bill;
		public const TORSO_DWN_FRM:String = "walk-2";

		public function BillLegs(bill:Bill,mc:MovieClip = null)
		{
			super(bill);
			if (mc)
				createMasterFromMc(mc);
			hasPState2 = true;
			this.bill = bill;
		}
		override public function checkFrame():void
		{
			var cl:String = currentLabel;
			if (cl == convLab("walkEnd"))
				setPlayFrame("walk-1");
			if (cl == convLab(TORSO_DWN_FRM))
			{
				bill.torso.y = bill.torsoDwnY;
				//if (bill.TD_TMR.running)
				//	bill.torso.y += 2;
			}
			else
				if (!bill.torsoDown)
				bill.torso.y = bill.torsoDefY;
		}
	}
}
