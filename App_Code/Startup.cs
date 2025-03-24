using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(EnglishLearningWebsite.Startup))]
namespace EnglishLearningWebsite
{
    public partial class Startup {
        public void Configuration(IAppBuilder app) {
            ConfigureAuth(app);
        }
    }
}
