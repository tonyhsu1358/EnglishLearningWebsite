using System;
using System.Collections.Generic;

public partial class bbb : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            var words = new List<dynamic>
            {
                new { Word = "administration", Type = "n.", Chinese = "管理", AudioUrl = "audio/administration.mp3" },
                new { Word = "celebrated",     Type = "adj.", Chinese = "著名的", AudioUrl = "audio/celebrated.mp3" },
                new { Word = "deplete",        Type = "v.", Chinese = "消耗", AudioUrl = "audio/deplete.mp3" },
                new { Word = "erect",          Type = "v.", Chinese = "豎立", AudioUrl = "audio/erect.mp3" },
                new { Word = "grasp",          Type = "v.", Chinese = "抓緊", AudioUrl = "audio/grasp.mp3" },
                new { Word = "jargon",         Type = "n.", Chinese = "行話", AudioUrl = "audio/jargon.mp3" },
                new { Word = "renowned",       Type = "adj.", Chinese = "有名的", AudioUrl = "audio/renowned.mp3" },
                new { Word = "accelerate",     Type = "v.", Chinese = "加速", AudioUrl = "audio/accelerate.mp3" },
                new { Word = "substantial",    Type = "adj.", Chinese = "大量的", AudioUrl = "audio/substantial.mp3" },
                new { Word = "allocate",       Type = "v.", Chinese = "分配", AudioUrl = "audio/allocate.mp3" }
            };

            rptWords.DataSource = words;
            rptWords.DataBind();
        }
    }
}
