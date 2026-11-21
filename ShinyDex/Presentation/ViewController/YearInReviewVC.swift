import UIKit

class YearInReviewVC: UIViewController {
    fileprivate let container: AppContainer
    fileprivate let scrollView = UIScrollView()
    fileprivate let pages = UIStackView()
    fileprivate let pageControl = UIPageControl()
    fileprivate var year: Int?
    fileprivate var cards = [YearInReviewCardView]()

    init(container: AppContainer, year: Int? = nil) {
        self.container = container
        self.year = year
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.Grey900
        navigationItem.largeTitleDisplayMode = .never
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        pages.axis = .horizontal
        pageControl.currentPageIndicatorTintColor = Color.Orange500
        pageControl.pageIndicatorTintColor = Color.Grey600
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)

        view.addAutoLayoutSubviews(scrollView, pageControl)
        scrollView.addAutoLayoutSubviews(pages)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            pages.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            pages.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            pages.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            pages.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            pages.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
        reloadReview()
    }

    fileprivate func reloadReview() {
        let review = container.getYearInReview.handle(GetYearInReviewQuery(year: year))
        year = review.year
        title = "\(review.year) in review"
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePressed))
        shareButton.accessibilityLabel = "Share card"
        let yearButton = UIBarButtonItem(title: String(review.year), menu: makeYearMenu(years: review.availableYears, selected: review.year))
        yearButton.accessibilityLabel = "Choose year"
        navigationItem.rightBarButtonItems = review.availableYears.count > 1 ? [shareButton, yearButton] : [shareButton]

        for page in pages.arrangedSubviews {
            pages.removeArrangedSubview(page)
            page.removeFromSuperview()
        }
        cards = YearInReviewCards(review: review, currentYear: Calendar.current.component(.year, from: Date())).makeContents().map {
            YearInReviewCardView(content: $0, footer: "ShinyDex · \(review.year)")
        }
        for card in cards {
            let page = UIView()
            page.addAutoLayoutSubviews(card)
            card.pinEdges(to: page, insets: UIEdgeInsets(top: 16, left: 20, bottom: 12, right: 20))
            pages.addArrangedSubview(page)
            page.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        }
        pageControl.numberOfPages = cards.count
        pageControl.currentPage = 0
        pageControl.isHidden = cards.count < 2
        view.layoutIfNeeded()
        scrollView.contentOffset = .zero
    }

    fileprivate func makeYearMenu(years: [Int], selected: Int) -> UIMenu {
        return UIMenu(title: "Year", children: years.map { year in
            UIAction(title: String(year), state: year == selected ? .on : .off) { [weak self] _ in
                self?.year = year
                self?.reloadReview()
            }
        })
    }

    fileprivate var currentPage: Int {
        guard scrollView.bounds.width > 0 else { return 0 }
        return min(max(Int((scrollView.contentOffset.x / scrollView.bounds.width).rounded()), 0), max(cards.count - 1, 0))
    }

    @objc fileprivate func pageControlChanged() {
        scrollView.setContentOffset(CGPoint(x: CGFloat(pageControl.currentPage) * scrollView.bounds.width, y: 0), animated: true)
    }

    @objc fileprivate func sharePressed() {
        guard cards.indices.contains(currentPage) else { return }
        let shareSheet = UIActivityViewController(activityItems: [cards[currentPage].renderImage()], applicationActivities: nil)
        shareSheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.first
        present(shareSheet, animated: true)
    }
}

extension YearInReviewVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
    }
}
