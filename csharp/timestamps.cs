public static string DateStamp
{
	get
	{
		return
			DateTime.Now.ToString("yyyyMMdd");
	}
}

public static string TimeStamp
{
	get
	{
		return
			DateTime.Now.ToString("yyyyMMdd-HHmmss");
	}
}

public static string TimeStampHighRes
{
	get
	{
		return
			DateTime.Now.ToString("yyyyMMdd-HHmmss.fff");
	}
}
