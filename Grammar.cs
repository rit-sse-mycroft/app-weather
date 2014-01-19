using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Speech.Recognition.SrgsGrammar;

namespace SRGS2XML
{
    class Example : ISRGSSpec
    {
        private SrgsDocument doc;

        public Example()
        {
            doc = new SrgsDocument();

            SrgsRule sunriseset = new SrgsRule("riseset");
            SrgsOneOf sunrisesetChoices = new SrgsOneOf("rise", "set");
            sunriseset.Add(sunrisesetChoices);
            sunriseset.Scope = SrgsRuleScope.Private;

            SrgsRuleRef sunrisesetRef = new SrgsRuleRef(sunriseset);

            SrgsRule days = new SrgsRule("days");
            SrgsOneOf dayChoices = new SrgsOneOf("today", "tomorrow", "currently");
            days.Add(dayChoices);
            days.Scope = SrgsRuleScope.Private;

            SrgsRuleRef dayRef = new SrgsRuleRef(days);

            SrgsRule weather = new SrgsRule("weather");
            SrgsRule sun = new SrgsRule("sun");

            SrgsItem question1 = new SrgsItem("Mycroft what is the weather");
            SrgsItem question2 = new SrgsItem("Mycroft When is sun");

            weather.Add(question1);
            weather.Add(dayRef);
            weather.Add(new SrgsSemanticInterpretationTag("out.day=rules.days;"));
            weather.Scope = SrgsRuleScope.Public;

            sun.Add(question2);
            sun.Add(sunrisesetRef);
            sun.Add(new SrgsSemanticInterpretationTag("out.rise_or_set=rules.riseset;"));
            sun.Add(dayRef);
            sun.Add(new SrgsSemanticInterpretationTag("out.day=rules.days;"));
            sun.Scope = SrgsRuleScope.Public;

            SrgsRule topLevel = new SrgsRule("toplevel");
            SrgsOneOf topLevelChoices = new SrgsOneOf(new SrgsItem(new SrgsRuleRef(weather)), new SrgsItem(new SrgsRuleRef(sun)));
            topLevel.Add(topLevelChoices);

            doc.Rules.Add(topLevel);
            doc.Rules.Add(weather);
            doc.Rules.Add(sun);
            doc.Rules.Add(days);
            doc.Rules.Add(sunriseset);



            doc.Root = topLevel;
        }

        public SrgsDocument SRGS()
        {
            return doc;
        }
    }
}
