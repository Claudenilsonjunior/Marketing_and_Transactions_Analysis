<div align="center">
  <h1>🛒 Nuvra Commerce — Growth Analytics Report</h1>
  <h3>How a Latin American e-commerce startup used data to diagnose stagnation and find its path to real growth</h3>
  <br>
  <img src="https://img.shields.io/badge/SQL%20Server-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white" />
  <img src="https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black" />
  <img src="https://img.shields.io/badge/Status-Complete-34d399?style=flat" />
</div>

---

<table align="center">
  <tr>
    <td width="1440">
      <h2 align="center">Company Background</h2>
      <p>
        <strong>Nuvra Commerce</strong> is a Latin American e-commerce startup founded in 2020, operating across six countries in the region. The company built its brand around a wide product catalog — spanning Electronics, Home, Fashion, Sports, Beauty, and Grocery — and positioned itself as a one-stop digital shopping destination for a growing middle-class consumer base.
      </p>
      <p>
        By 2021, Nuvra had scaled to over <strong>100,000 registered customers</strong> and was processing more than <strong>100,000 transactions per year</strong>, generating hundreds of millions in gross revenue. On paper, the numbers looked impressive. The company had successfully raised a Series B round and was planning its next phase of expansion into new markets.
      </p>
      <p>
        But behind the headline numbers, the leadership team was facing a problem they could not fully articulate — and that was exactly the issue.
      </p>

      <h2 align="center">The Problem</h2>
      <p>
        Heading into 2023, Nuvra's Chief Commercial Officer brought a concern to the board: <strong>the business had been generating strong revenue for two years, but growth had flatlined</strong>. Month after month, the numbers looked similar. Marketing spend was increasing. The customer acquisition engine was running at full capacity. But net revenue per customer was not moving, repeat purchase rates were unclear, and no one could point to a single cohort of customers that was behaving better than any other.
      </p>
      <p>
        Three specific questions were keeping the leadership team up at night:
      </p>
      <ul>
        <li><strong>Are we actually growing, or are we just replacing the customers we lose every month?</strong> The team suspected that a large portion of acquired customers were one-time buyers, but had no data to confirm it or quantify the impact.</li>
        <li><strong>Are our campaigns working?</strong> Nuvra was running 50 active marketing campaigns across five channels. Budget allocation was based on expected uplift figures that had never been validated against real conversion data.</li>
        <li><strong>Where should we focus product investment?</strong> With six categories and thousands of SKUs, the team had no clear view of which categories were driving profitable revenue and which were consuming operational resources without proportional return.</li>
      </ul>
      <p>
        An internal analytics review was commissioned, covering three full years of data (2021–2023) across the company's five core data systems: customer profiles, product catalog, marketing campaigns, user interaction events, and purchase transactions.
      </p>

      <h2 align="center">The North Star</h2>
      <blockquote>
        <strong>Net Revenue per Active Customer: $13,103</strong><br>
        The analysis established this as the single metric that every strategic decision should aim to move — combining revenue quality (excluding refunds) with genuine customer engagement (only counting customers who actually purchased).
      </blockquote>

      <h3>The review covered six areas</h3>
      <ul>
        <li><strong>Revenue & Profitability</strong> — Total revenue, refund impact, discount behavior, and month-over-month growth trends.</li>
        <li><strong>Retention & Loyalty</strong> — Repurchase rates, the financial value of a second purchase, and loyalty program effectiveness.</li>
        <li><strong>Campaign & Channel Performance</strong> — Which channels and campaign objectives actually drive revenue.</li>
        <li><strong>Product Performance</strong> — Category revenue, premium vs standard dynamics, and refund rates by product.</li>
        <li><strong>Customer Segmentation</strong> — RFM analysis identifying Champions, Loyal, Potential, and At Risk customers.</li>
        <li><strong>Funnel & Conversion</strong> — Where customers drop off and which devices and traffic sources convert best.</li>
      </ul>
    </td>
  </tr>
</table>

---

<table align="center">
  <tr>
    <td width="1440">
      <h1 align="center">Executive Summary</h1>
      <h3 align="center">Revenue Performance (Jan 2021 – Dec 2023)</h3>
      <div align="center">
        <img width="1000" alt="Monthly net revenue 2021–2023" src="YOUR_REVENUE_CHART_IMAGE_URL_HERE" />
      </div>
      <br>
      <table>
        <tr>
          <td width="480" valign="top">
            <ol>
              <li>
                <strong>Strong absolute revenue — zero real growth</strong>
                <ul>
                  <li>Nuvra generated <strong>$772.9 million in net revenue</strong> over three years. A number the board had celebrated. But comparing January 2021, January 2022, and January 2023 reveals a flat line — the business was not expanding, it was maintaining.</li>
                  <li>Month-over-month growth that appeared in internal reports was almost entirely explained by seasonal patterns repeating themselves. There was no underlying commercial acceleration.</li>
                </ul>
              </li>
              <li>
                <strong>Seasonality is predictable — and underutilized</strong>
                <ul>
                  <li>November and December consistently ran <strong>25–30% above the monthly average</strong>. February was consistently the weakest month across all three years.</li>
                  <li>These patterns were known but not operationalized. Campaign planning, inventory, and budget cycles were not aligned to the rhythm the data clearly showed.</li>
                </ul>
              </li>
            </ol>
          </td>
          <td width="480" valign="top">
            <ol start="3">
              <li>
                <strong>Refund rates are healthy — not the problem</strong>
                <ul>
                  <li>Of $796.3 million in gross revenue, <strong>only $23.3 million (2.93%) was refunded</strong> — well below the 5–15% benchmark for e-commerce. Product quality and post-purchase satisfaction are not areas of concern.</li>
                </ul>
              </li>
              <li>
                <strong>Discounts are eroding margin without a clear return</strong>
                <ul>
                  <li><strong>40% of all transactions included a discount</strong> at an average of 5.46% off, generating 7% less revenue per order than full-price transactions — with no evidence of incremental purchase volume in return.</li>
                  <li>Nuvra was effectively leaving margin on the table for customers who would have bought anyway.</li>
                </ul>
              </li>
            </ol>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

---

<h2 align="center">Dataset Structure</h2>
<p align="center">The analysis was built on five interconnected data tables with a combined total of over 2.2 million records.</p>

<div align="center">
  <img width="700" alt="Entity Relationship Diagram" src="YOUR_ERD_IMAGE_URL_HERE" />
</div>

---

<h1 align="center">Insights Deep-Dive</h1>

<table align="center">
  <tr>
    <td width="1440">
      <h1 align="center">Retention & Loyalty</h1>
      <div align="center">
        <img width="1000" alt="Retention and loyalty dashboard" src="YOUR_RETENTION_DASHBOARD_IMAGE_URL_HERE" />
      </div>
      <br>
      <table>
        <tr>
          <td width="480" valign="top">
            <h3>The answer to question one</h3>
            <p>The leadership team suspected they were losing customers. The data confirmed it — and quantified it.</p>
            <ul>
              <li><strong>61.7% of Nuvra's customers bought only once</strong> and never returned. The acquisition engine was not building a customer base — it was filling a leaky bucket.</li>
              <li>Nuvra was acquiring approximately 2,800 new customers every month at a consistent pace. But the majority disappeared after their first purchase, meaning every new customer was essentially replacing one who had already left.</li>
              <li>The retention rate sat at <strong>38.34%</strong> — just over one in three customers returned for a second purchase.</li>
            </ul>
            <h3>The value of a second purchase</h3>
            <ul>
              <li>A one-time buyer generates <strong>$8,568 on average</strong>. A customer with two or three purchases generates <strong>$19,251 — a 124% increase</strong> in lifetime value from a single repeat transaction.</li>
              <li>Customers with two or three purchases represent 35.8% of the base but generate <strong>52.6% of all revenue</strong>.</li>
              <li>This is the single most important finding for Nuvra's growth strategy: the path to real revenue growth is not acquiring more customers — it is keeping the ones already acquired.</li>
            </ul>
          </td>
          <td width="480" valign="top">
            <h3>The repurchase window</h3>
            <ul>
              <li>Customers who do return take their time. The <strong>median gap between a first and second purchase is 283 days</strong> — nearly nine months.</li>
              <li>This means that a customer who bought six months ago has not necessarily churned. They may simply be approaching their natural repurchase point — and Nuvra has not been reaching out to them during that window.</li>
              <li>Re-engagement campaigns need to operate on a long horizon, with structured touchpoints at 30, 90, 180, and 270 days post-purchase.</li>
            </ul>
            <h3>The loyalty program is not driving loyalty</h3>
            <ul>
              <li>The retention gap between Platinum tier (46.89%) and Bronze tier (34.55%) is only <strong>12 percentage points</strong> — far too small for a program designed to meaningfully differentiate customer behavior.</li>
              <li>The average number of purchases per customer never exceeds 1.71 in any tier. The program is not creating the habit of returning.</li>
              <li>Most strikingly: <strong>six of Nuvra's top ten highest-spending customers are Bronze tier</strong>. The program is not identifying or rewarding the customers who matter most.</li>
            </ul>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

---

<table align="center">
  <tr>
    <td width="1440">
      <h1 align="center">Campaign & Channel Performance</h1>
      <div align="center">
        <img width="1000" alt="Campaign and channel dashboard" src="YOUR_CAMPAIGN_DASHBOARD_IMAGE_URL_HERE" />
      </div>
      <br>
      <table>
        <tr>
          <td width="480" valign="top">
            <h3>The answer to question two</h3>
            <p>Nuvra was running 50 campaigns across five channels with budget allocated based on expected uplift figures. The data showed those figures were not grounded in reality.</p>
            <ul>
              <li>Actual conversion rates across all 50 campaigns fell in a narrow band between <strong>4.73% and 11.22%</strong> — regardless of how high the expected uplift was declared. Only three campaigns out of fifty met or exceeded their targets, and all three had the most conservative expectations (1–3%).</li>
              <li>Campaign budgets were being allocated against targets that had never been validated. The result was misallocated spend across the board.</li>
            </ul>
            <h3>What actually works</h3>
            <ul>
              <li><strong>Affiliate is the top-performing channel</strong> by revenue ($147.9 million), followed by Paid Search ($141.4 million).</li>
              <li><strong>Reactivation campaigns outperformed Acquisition campaigns</strong> in total revenue generated ($180 million vs $121 million) — a direct signal that Nuvra should be spending more on re-engaging existing customers than on acquiring new ones.</li>
              <li>Social media brings significant traffic but converts poorly. It is a discovery channel — not a conversion channel — and should be measured accordingly.</li>
            </ul>
          </td>
          <td width="480" valign="top">
            <h3>Traffic source conversion</h3>
            <ul>
              <li><strong>Paid Search converts best at 26.60%</strong> — users arriving from search have clear purchase intent and represent the highest-quality inbound traffic.</li>
              <li>Email converts at 22.51%, reflecting the value of reaching customers who already have a relationship with the brand.</li>
              <li>Direct traffic converts at only 4.26% — the lowest of all sources. This reinforces the retention finding: very few customers return to Nuvra deliberately, and those who do are not always in a buying mindset.</li>
            </ul>
            <h3>Average order value is channel-agnostic</h3>
            <ul>
              <li>AOV is virtually identical across all channels ($8,548–$8,604). Channel does not influence how much a customer spends per order — it only determines whether they arrive at all.</li>
              <li>This means channel optimization should focus entirely on conversion rate and cost of acquisition — not on influencing spend per transaction.</li>
            </ul>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

---

<table align="center">
  <tr>
    <td width="1440">
      <h1 align="center">Product Performance</h1>
      <div align="center">
        <img width="1000" alt="Product performance dashboard" src="YOUR_PRODUCT_DASHBOARD_IMAGE_URL_HERE" />
      </div>
      <br>
      <table>
        <tr>
          <td width="320" valign="top">
            <h3>The answer to question three</h3>
            <p>Not all of Nuvra's six categories are equal — and the data made the hierarchy unmistakable.</p>
            <ul>
              <li><strong>Electronics accounts for 41% of total net revenue</strong> ($317 million) with an average order value of $15,026. It is the engine of the business.</li>
              <li>Home is the most balanced category ($187 million, lowest refund rate at 2.75%) — high value, high volume, low risk.</li>
              <li>Fashion sells in volume but at low margin ($6,096 AOV). It contributes to transaction count but not to revenue quality.</li>
              <li>Grocery is the strategic question mark: 14,431 transactions at $1,835 AOV. High operational cost, low revenue return. Its place in the catalog needs to be justified.</li>
            </ul>
          </td>
          <td width="320" valign="top">
            <h3>Premium vs standard</h3>
            <ul>
              <li>Premium and standard products generate <strong>nearly identical transaction volumes</strong> — but premium generates <strong>3.4 times more revenue per transaction</strong> ($12,837 vs $3,808).</li>
              <li>Refund rates are virtually identical between the two tiers. Premium products carry no additional return risk.</li>
              <li>This is the clearest product insight in the entire analysis: shifting the transaction mix toward premium is the most direct lever available for increasing revenue without increasing customer volume.</li>
            </ul>
          </td>
          <td width="320" valign="top">
            <h3>The untapped opportunity in Beauty</h3>
            <ul>
              <li>Beauty has <strong>8,638 standard transactions and only 300 premium</strong> — the largest imbalance of any category in the catalog.</li>
              <li>Premium Beauty products carry an average order value of $9,428 vs $3,655 for standard — a 2.6x difference with no meaningful difference in refund rates.</li>
              <li>The customer appetite for Beauty is already demonstrated. The gap is entirely in premium product discovery, recommendation, and merchandising.</li>
            </ul>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

---

<table align="center">
  <tr>
    <td width="1440">
      <h1 align="center">Customer Segmentation — RFM Analysis</h1>
      <div align="center">
        <img width="1000" alt="RFM segmentation dashboard" src="YOUR_RFM_DASHBOARD_IMAGE_URL_HERE" />
      </div>
      <br>
      <p>To understand who Nuvra's customers actually are — beyond aggregate numbers — a Recency, Frequency, and Monetary segmentation was built across the full customer base.</p>
      <br>
      <table align="center">
        <tr>
          <th align="left">Segment</th>
          <th align="left">Customers</th>
          <th align="left">% of Revenue</th>
          <th align="left">Avg Revenue / Customer</th>
          <th align="left">Avg Days Since Last Purchase</th>
        </tr>
        <tr>
          <td><strong>Champions</strong></td>
          <td>15,816</td>
          <td>52.28%</td>
          <td>$25,548</td>
          <td>214 days</td>
        </tr>
        <tr>
          <td><strong>Loyal</strong></td>
          <td>20,902</td>
          <td>29.04%</td>
          <td>$10,739</td>
          <td>356 days</td>
        </tr>
        <tr>
          <td><strong>Potential</strong></td>
          <td>12,986</td>
          <td>14.04%</td>
          <td>$8,356</td>
          <td>620 days</td>
        </tr>
        <tr>
          <td><strong>At Risk</strong></td>
          <td>9,283</td>
          <td>4.64%</td>
          <td>$3,861</td>
          <td>884 days</td>
        </tr>
      </table>
      <br>
      <table>
        <tr>
          <td width="480" valign="top">
            <ul>
              <li><strong>15,816 customers — 26.8% of the base — generate 52.28% of Nuvra's revenue.</strong> Their average revenue per customer ($25,548) is nearly double the North Star. This is the segment that is sustaining the business while the retention problem plays out beneath the surface.</li>
              <li>The <strong>Loyal segment is the most urgent short-term risk</strong>. 20,902 customers with an average of 356 days since their last purchase — already past the 283-day median repurchase window. Without active outreach, many of these customers will quietly move into Potential, representing a drop from $10,739 to $8,356 in average lifetime value each.</li>
            </ul>
          </td>
          <td width="480" valign="top">
            <ul>
              <li>The <strong>Potential segment</strong> (12,986 customers, 620 days since last purchase) is largely composed of one-time buyers who spent well when they did purchase. A targeted reactivation campaign — particularly for those within 18 months of their last purchase — has a realistic chance of recovery.</li>
              <li>The <strong>At Risk segment</strong> (884 days average recency, 1.00 avg purchases) bought once nearly three years ago and never returned. The cost of reactivating this group likely exceeds the expected return for most customers. Resources are better directed at Champions, Loyal, and high-value Potential customers.</li>
            </ul>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

---

<table align="center">
  <tr>
    <td width="1440">
      <h1 align="center">Funnel & Conversion</h1>
      <div align="center">
        <img width="1000" alt="Funnel and conversion dashboard" src="YOUR_FUNNEL_DASHBOARD_IMAGE_URL_HERE" />
      </div>
      <br>
      <table>
        <tr>
          <td width="480" valign="top">
            <h3>Where Nuvra's funnel holds</h3>
            <ul>
              <li><strong>97.73% of customers who view a product go on to click it.</strong> 96.42% of those who click add the product to their cart. The catalog experience, product pages, and browsing flow are working — customers who engage are highly likely to keep moving.</li>
              <li>The product itself is not the problem. The problem is what happens next.</li>
            </ul>
            <h3>Where it breaks</h3>
            <ul>
              <li><strong>36.23% of customers who add a product to their cart do not complete the purchase.</strong> Of every 100 customers who reach the cart, 36 leave without buying — after already demonstrating clear purchase intent.</li>
              <li>This is the single highest-leverage point in the entire funnel. A 10-point reduction in cart abandonment would recover approximately 3,400 purchases that Nuvra is currently losing at the final step.</li>
            </ul>
          </td>
          <td width="480" valign="top">
            <h3>Device and traffic source</h3>
            <ul>
              <li><strong>Mobile converts at 41.77%</strong>, making it Nuvra's most effective device by a significant margin. Desktop follows at 27.20%.</li>
              <li>Tablet converts at only <strong>7.16%</strong> despite 62,448 customers using the device. This level of drop-off on a device with meaningful usage volume points to a specific UX friction point — likely in the checkout flow — that is suppressing a quantifiable number of purchases.</li>
              <li>85% of customers registered at least one bounce event, but <strong>60% of those customers went on to make a purchase</strong>. Bounce on Nuvra's platform is not a signal of lost intent — it is a signal of a non-linear journey. 34,031 customers who bounced and never purchased represent a defined, reachable segment for re-engagement.</li>
            </ul>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

---

<table align="center">
  <tr>
    <td width="1440">
      <h1 align="center">Cohort Analysis</h1>
      <div align="center">
        <img width="1000" alt="Cohort analysis dashboard" src="YOUR_COHORT_DASHBOARD_IMAGE_URL_HERE" />
      </div>
      <br>
      <table>
        <tr>
          <td width="480" valign="top">
            <h3>The structural diagnosis</h3>
            <ul>
              <li>Across 36 monthly cohorts (January 2021 to December 2023), average lifetime value ranged from <strong>$12,655 to $13,863</strong> with no trend in either direction.</li>
              <li>No cohort broke the pattern. Every group of customers acquired in any given month behaved almost identically to every other group — regardless of the season, the campaigns active at the time, or the year of acquisition.</li>
              <li>This is the most definitive finding in the analysis: <strong>Nuvra's stagnation is structural, not situational.</strong> It is not a bad quarter. It is not one weak campaign cycle. It is a ceiling the business has not broken in three years — and cohort data is the clearest proof of that.</li>
            </ul>
          </td>
          <td width="480" valign="top">
            <h3>What the ceiling looks like</h3>
            <ul>
              <li>Average purchases per customer stayed between <strong>1.48 and 1.56 in every single cohort.</strong> A range so narrow it is effectively flat regardless of any external variable.</li>
              <li>February cohorts are consistently the smallest in customers acquired across all three years — mirroring the weakest transaction months in the full revenue dataset.</li>
              <li>Every cohort shows a consistent gap between lifetime value ($13,103 average) and average order value ($8,590) — a gap of approximately $4,500 that represents the financial contribution of the repeat purchase. The ceiling exists because no cohort has been able to push customers reliably beyond their first or second transaction.</li>
            </ul>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

---

<table align="center">
  <tr>
    <td width="1440">
      <h1 align="center">Recommendations</h1>
      <h4>The analysis gave Nuvra's leadership team a clear answer to each of their three questions — and a concrete set of actions to move forward.</h4>

      <h3>On retention — yes, you are replacing the customers you lose</h3>
      <ul>
        <li>
          <strong>Build a structured re-engagement sequence for one-time buyers.</strong>
          <ul>
            <li>The 283-day median repurchase window means the conversation with a customer cannot end at delivery confirmation. Deploy touchpoints at 30–60 days (follow-up and cross-sell), 90–120 days (first active re-engagement), 180 days (incentive offer), and 270–300 days (final recovery before the window closes).</li>
            <li>Converting even 10% of the 36,369 one-time buyers into returning customers at the 2–3 purchase revenue level of $19,251 would add over <strong>$39 million in incremental revenue</strong> — without acquiring a single new customer.</li>
          </ul>
        </li>
        <li>
          <strong>Protect Champions before they drift.</strong>
          <ul>
            <li>15,816 customers generate 52.28% of revenue. A dedicated VIP program — early access, personalized outreach, priority service — should activate before these customers approach the 214-day recency mark. A Champion who moves to Loyal represents an average revenue drop of $14,809 per customer.</li>
          </ul>
        </li>
        <li>
          <strong>Rebuild the loyalty program around purchase behavior.</strong>
          <ul>
            <li>Tiers should be earned through spending thresholds and renewed through purchasing — not assigned at signup. The current structure misclassifies the most valuable customers and creates no meaningful incentive to return.</li>
          </ul>
        </li>
      </ul>

      <h3>On campaigns — reallocate before you scale</h3>
      <ul>
        <li>
          <strong>Stop allocating budget based on declared uplift figures.</strong>
          <ul>
            <li>47 of 50 campaigns underperformed their targets. Planning against unvalidated expectations is producing predictable misallocation. Future budget decisions should be based on actual historical conversion rates by channel and objective.</li>
          </ul>
        </li>
        <li>
          <strong>Shift the mix from acquisition toward reactivation.</strong>
          <ul>
            <li>Reactivation already generates $59 million more than acquisition campaigns. More acquisition spend will not solve the retention problem — it will deepen it by adding more one-time buyers to the base without addressing why they are not coming back.</li>
          </ul>
        </li>
        <li>
          <strong>Implement targeted discounting.</strong>
          <ul>
            <li>40% of transactions use a discount with no measurable benefit in volume. Reserve discounts for cart abandonment recovery, lapsed customer reactivation, and first-purchase incentives — situations where the discount is the deciding factor between a sale and no sale.</li>
          </ul>
        </li>
      </ul>

      <h3>On product — concentrate where the return is clearest</h3>
      <ul>
        <li>
          <strong>Invest in premium product discovery — starting with Beauty.</strong>
          <ul>
            <li>Beauty has 8,638 standard transactions and 300 premium despite a 2.6x AOV advantage for premium. Targeted recommendation flows, editorial content, and campaign investment in premium Beauty could shift the mix materially without new customer acquisition.</li>
          </ul>
        </li>
        <li>
          <strong>Reassess Grocery's role in the catalog.</strong>
          <ul>
            <li>14,431 transactions at $1,835 AOV generate the lowest revenue of any category. The cost of fulfillment, customer service, and returns handling for Grocery transactions likely does not justify the return relative to Electronics ($15,026 AOV) or Home ($10,132 AOV).</li>
          </ul>
        </li>
        <li>
          <strong>Fix the cart — and audit the tablet experience.</strong>
          <ul>
            <li>36.23% cart abandonment is the only meaningful drop-off in the funnel. A three-step abandonment email at 1 hour, 24 hours, and 72 hours recovers customers who were already decided. Tablet's 7.16% conversion rate on 62,448 users points to a specific checkout friction that a UX audit would likely surface quickly.</li>
          </ul>
        </li>
      </ul>
    </td>
  </tr>
</table>

---

<h2 align="center">Dashboard</h2>
<p align="center">A seven-page Power BI dashboard was built to give Nuvra's leadership team a live view of every finding in this report.</p>

<div align="center">
  <img width="1000" alt="Executive overview dashboard" src="YOUR_EXECUTIVE_OVERVIEW_IMAGE_URL_HERE" />
</div>

<table align="center">
  <tr>
    <th>Page</th>
    <th>Focus</th>
  </tr>
  <tr>
    <td>Executive Overview</td>
    <td>North Star, revenue summary, RFM distribution, funnel snapshot</td>
  </tr>
  <tr>
    <td>Revenue & Profitability</td>
    <td>MoM growth, refund analysis, discount impact, revenue concentration</td>
  </tr>
  <tr>
    <td>Retention & Loyalty</td>
    <td>Retention rate, repurchase value, LTV by RFM segment, loyalty tier behavior</td>
  </tr>
  <tr>
    <td>Campaign & Channel</td>
    <td>Channel revenue, campaign conversion, uplift vs expectation, traffic source</td>
  </tr>
  <tr>
    <td>Product Performance</td>
    <td>Category revenue, premium vs standard, refund rates, top 10 products</td>
  </tr>
  <tr>
    <td>Funnel & Conversion</td>
    <td>Full funnel drop-off, device and traffic source conversion, bounce recovery</td>
  </tr>
  <tr>
    <td>Cohort Analysis</td>
    <td>LTV by signup cohort, purchase frequency trends, acquisition patterns</td>
  </tr>
</table>

---

<h2 align="center">Technical Stack</h2>

<table align="center">
  <tr>
    <th>Tool</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td>SQL Server Management Studio</td>
    <td>Data storage, exploration, cleaning, and analytical view creation</td>
  </tr>
  <tr>
    <td>Power BI</td>
    <td>Dashboard design and data visualization</td>
  </tr>
  <tr>
    <td>DAX</td>
    <td>Business metric and KPI calculation</td>
  </tr>
  <tr>
    <td>GitHub</td>
    <td>Version control and project documentation</td>
  </tr>
</table>

---

<div align="center">
  <p><em>Nuvra Commerce is a fictional company created for portfolio purposes. All data is synthetic and does not represent any real business or individuals.</em></p>
</div>
